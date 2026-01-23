resource "hcloud_network" "vpc" {
    name     = "vpc"
    ip_range = var.vpc_master_subnet
}

resource "hcloud_network_subnet" "k3s_master" {
    network_id   = hcloud_network.vpc.id
    type         = "cloud"
    network_zone = "eu-central"
    ip_range     = var.subnet_k3s_master_cidr
}

resource "hcloud_network_subnet" "k3s_worker" {
    network_id   = hcloud_network.vpc.id
    type         = "cloud"
    network_zone = "eu-central"
    ip_range     = var.subnet_k3s_worker_cidr
}
