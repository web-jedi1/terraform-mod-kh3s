resource "local_file" "service_user_public" {
    filename             = "${path.module}/ansible/${var.cert_out_dir}/service_user.pub"
    content              = tls_private_key.k3s_service_user_key.public_key_openssh
    file_permission      = "0644"
    directory_permission = "0700"
}

resource "local_file" "service_user_private" {
    filename             = "${path.module}/ansible/${var.cert_out_dir}/service_user.pem"
    sensitive_content    = tls_private_key.k3s_service_user_key.private_key_openssh
    file_permission      = "0600"
    directory_permission = "0700"
}

resource "local_file" "ansible_user_public" {
    filename             = "${path.module}/ansible/${var.cert_out_dir}/ansible_user.pub"
    content              = tls_private_key.k3s_ansible_user_key.public_key_openssh
    file_permission      = "0644"
    directory_permission = "0700"
}

resource "local_file" "ansible_user_private" {
    filename             = "${path.module}/ansible/${var.cert_out_dir}/ansible_user.pem"
    sensitive_content    = tls_private_key.k3s_ansible_user_key.private_key_openssh
    file_permission      = "0600"
    directory_permission = "0700"
}

output "key_file_paths" {
    value = {
        service_user_public  = local_file.service_user_public.filename
        service_user_private = local_file.service_user_private.filename
        ansible_user_public  = local_file.ansible_user_public.filename
        ansible_user_private = local_file.ansible_user_private.filename
    }
}

output "k3s_master_ips" {
    description = "Static IPs for Kubernetes master nodes"
    value = {
        for name, server in hcloud_server.k3s_masters :
        name => server.ipv4_address
    }
}

output "k3s_worker_ips" {
    description = "Static IPs for Kubernetes worker nodes"
    value = {
        for name, server in hcloud_server.k3s_workers :
        name => server.ipv4_address
    }
}

# Ansible inventory (INI format)
resource "local_file" "ansible_inventory" {
    filename = "${path.module}/ansible/inventory/hosts.ini"

    content = <<-EOT
[k3s_masters]
%{ for name, srv in hcloud_server.k3s_masters ~}
${name} ansible_host=${srv.ipv4_address} ansible_host_private=${one(srv.network).ip} ansible_user=${var.k3s_user_name_ansible} hetzner_instance_type=${local.server_k3s_master_node_definitions[name].server_type} env=${local.server_k3s_master_node_definitions[name].environment}
%{ endfor ~}

[k3s_workers]
%{ for name, srv in hcloud_server.k3s_workers ~}
${name} ansible_host=${srv.ipv4_address} ansible_host_private=${one(srv.network).ip} ansible_user=${var.k3s_user_name_ansible} hetzner_instance_type=${local.server_k3s_worker_node_definitions[name].server_type} env=${local.server_k3s_worker_node_definitions[name].environment} workload=${local.server_k3s_worker_node_definitions[name].workload}
%{ endfor ~}
EOT

    file_permission = "0640"
}

resource "local_file" "ansible_config" {
  filename = "${path.module}/ansible/ansible.cfg"
  content = templatefile("${path.module}/templates/ansible.cfg.tftpl", {
    service_user     = var.k3s_user_name_ansible
    service_user_key = "${var.cert_out_dir}/ansible_user.pem"
    inventory_file   = local_file.ansible_inventory.filename
  })
}

output "lb_private_ip" {
    value = hcloud_load_balancer_network.lb_net.ip
}

output "lb_public_ip" {
    value = hcloud_load_balancer.load_balancer.ipv4
}
