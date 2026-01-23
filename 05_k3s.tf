resource "hcloud_server" "k3s_masters" {
    for_each    = local.server_k3s_master_node_definitions
    name        = each.key
    image       = var.k3s_os_image
    server_type = each.value.server_type
    location    = var.cluster_region
    labels = {
        "classification" : each.value.classification
    }

    network {
        network_id = hcloud_network.vpc.id
        ip         = each.value.ip
        alias_ips  = []
    }
    public_net {
        ipv4_enabled = true
        ipv6_enabled = false
    }

    user_data = templatefile("${path.module}/templates/k3s-masters-cloud-init.yml.tftpl", {
        hostname               = each.value.hostname
        service_user_name      = var.k3s_user_name_service
        service_user_key       = tls_private_key.k3s_service_user_key.public_key_openssh
        ansible_user_name      = var.k3s_user_name_ansible
        ansible_user_key       = tls_private_key.k3s_ansible_user_key.public_key_openssh
        subnet_k3s_master_cidr = var.subnet_k3s_master_cidr
        subnet_k3s_worker_cidr = var.subnet_k3s_worker_cidr
    })
    
    depends_on = [
        hcloud_network_subnet.k3s_master
    ]
}

resource "hcloud_server" "k3s_workers" {
    for_each    = local.server_k3s_worker_node_definitions
    name        = each.key
    image       = var.k3s_os_image
    server_type = each.value.server_type
    location    = var.cluster_region
    labels = {
        "classification" : each.value.classification
    }

    public_net {
        ipv4_enabled = true
        ipv6_enabled = false
    }
    network {
        network_id = hcloud_network.vpc.id
        ip         = each.value.ip
        alias_ips  = []
    }

    user_data = templatefile("${path.module}/templates/k3s-masters-cloud-init.yml.tftpl", {
        hostname = each.value.hostname
        service_user_name      = var.k3s_user_name_service
        service_user_key       = tls_private_key.k3s_service_user_key.public_key_openssh
        ansible_user_name      = var.k3s_user_name_ansible
        ansible_user_key       = tls_private_key.k3s_ansible_user_key.public_key_openssh
        subnet_k3s_master_cidr = var.subnet_k3s_master_cidr
        subnet_k3s_worker_cidr = var.subnet_k3s_worker_cidr
        lb_ip                  = var.lb_internal_ip
    })
    
    depends_on = [
        hcloud_network_subnet.k3s_worker
    ]
}
