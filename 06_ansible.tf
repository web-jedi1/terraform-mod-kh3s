resource "null_resource" "wait_for_ssh" {
    for_each = merge(
        hcloud_server.k3s_masters,
        hcloud_server.k3s_workers
    )

    provisioner "remote-exec" {
        inline = [
            "echo SSH is ready for ${each.key}"
        ]

        connection {
            type        = "ssh"
            user        = var.k3s_user_name_ansible
            private_key = file(local_file.ansible_user_private.filename)
            host        = each.value.ipv4_address
            timeout     = "2m"
        }
    }

    depends_on = [
        hcloud_server.k3s_masters,
        hcloud_server.k3s_workers
    ]
}

resource "time_sleep" "wait_after_init" {
    depends_on = [
        null_resource.wait_for_ssh
    ]
    create_duration = "30s"
}

resource "null_resource" "ansible_bootstrap_masters" {
    count = var.bootstrap_kubernetes ? 1 : 0
    triggers = {
        ansible_playbook_sha = filemd5("${path.module}/ansible/playbooks/k3s-master.yml")
        master_ids = join(",", [for server in hcloud_server.k3s_masters : server.id])
    }

    provisioner "local-exec" {
        command = <<EOT
set -e
ansible-playbook -i ${path.module}/ansible/inventory/hosts.ini ${path.module}/ansible/playbooks/k3s-master.yml
EOT

        environment = {
            ANSIBLE_CONFIG = "${path.module}/ansible/ansible.cfg"
        }
    }
    

    depends_on = [
        null_resource.wait_for_ssh,
        time_sleep.wait_after_init
    ]
}

resource "time_sleep" "wait_after_masters" {
    depends_on = [
        null_resource.ansible_bootstrap_masters
    ]
    create_duration = "15s"
}

resource "null_resource" "ansible_bootstrap_workers" {
    count = var.bootstrap_kubernetes ? 1 : 0

    triggers = {
        ansible_playbook_sha = filemd5("${path.module}/ansible/playbooks/k3s-worker.yml")
        worker_ids = join(",", [for server in hcloud_server.k3s_workers : server.id])
    }

    provisioner "local-exec" {
        command = <<EOT
set -e
ansible-playbook -i ${path.module}/ansible/inventory/hosts.ini ${path.module}/ansible/playbooks/k3s-worker.yml
EOT

        environment = {
            ANSIBLE_CONFIG = "${path.module}/ansible/ansible.cfg"
        }
    }

    depends_on = [
        null_resource.ansible_bootstrap_masters,
        time_sleep.wait_after_masters
    ]
}

resource "time_sleep" "wait_after_workers" {
    depends_on = [
        null_resource.ansible_bootstrap_workers
    ]
    create_duration = "10s"
}

resource "null_resource" "ansible_bootstrap_k3s" {
    count = var.bootstrap_kubernetes ? 1 : 0

    triggers = {
        ansible_playbook_sha = filemd5("${path.module}/ansible/playbooks/k3s-bootstrap.yml")
        master_ids = join(",", [for server in hcloud_server.k3s_masters : server.id])
    }

    provisioner "local-exec" {
        command = <<EOT
set -e
ansible-playbook -i ${path.module}/ansible/inventory/hosts.ini ${path.module}/ansible/playbooks/k3s-bootstrap.yml
EOT

        environment = {
            ANSIBLE_CONFIG = "${path.module}/ansible/ansible.cfg"
        }
    }

    depends_on = [
        null_resource.ansible_bootstrap_workers,
        time_sleep.wait_after_workers
    ]
}

resource "time_sleep" "wait_after_bootstrap" {
    depends_on = [
        null_resource.ansible_bootstrap_k3s
    ]
    create_duration = "5s"
}

resource "null_resource" "ansible_bootstrap_flux" {
    count = (var.bootstrap_kubernetes && var.bootstrap_flux )? 1 : 0

    triggers = {
        ansible_playbook_sha = filemd5("${path.module}/ansible/playbooks/k3s-flux.yml")
        master_ids = join(",", [for server in hcloud_server.k3s_masters : server.id])
    }

    provisioner "local-exec" {
        command = <<EOT
set -e
ansible-playbook -i ${path.module}/ansible/inventory/hosts.ini ${path.module}/ansible/playbooks/k3s-flux.yml
EOT

        environment = {
            ANSIBLE_CONFIG = "${path.module}/ansible/ansible.cfg"
            FLUX_GIT_TOKEN = var.flux_git_token
            FLUX_GIT_URL   = var.flux_git_url
        }
    }

      depends_on = [
          null_resource.ansible_bootstrap_k3s,
          time_sleep.wait_after_bootstrap
      ]
}

resource "time_sleep" "wait_after_flux" {
    depends_on = [
        null_resource.ansible_bootstrap_flux
    ]
    create_duration = "5s"
}
