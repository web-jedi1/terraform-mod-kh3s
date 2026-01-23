resource "tls_private_key" "k3s_service_user_key" {
    algorithm = "ED25519"
}

resource "hcloud_ssh_key" "k3s_service_user_key" {
    name       = "${var.k3s_user_name_service}"
    public_key = tls_private_key.k3s_service_user_key.public_key_openssh
}

resource "tls_private_key" "k3s_ansible_user_key" {
    algorithm = "ED25519"
}

resource "hcloud_ssh_key" "k3s_ansible_user_key" {
    name       = "${var.k3s_user_name_ansible}"
    public_key = tls_private_key.k3s_ansible_user_key.public_key_openssh
}
