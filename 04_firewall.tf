resource "hcloud_firewall" "cluster_fw" {
    name = "cluster-firewall"

    rule {
        direction = "in"
        protocol  = "tcp"
        port      = "22"
        source_ips = ["0.0.0.0/0"]
    }

    rule {
        direction = "out"
        protocol  = "tcp"
        port      = "1-65535"
        destination_ips = ["0.0.0.0/0"]
    }

    rule {
        direction = "out"
        protocol  = "udp"
        port      = "1-65535"
        destination_ips = ["0.0.0.0/0"]
    }
}

resource "hcloud_firewall_attachment" "masters" {
    firewall_id = hcloud_firewall.cluster_fw.id
    server_ids  = concat(
      [for server in hcloud_server.k3s_masters : server.id],
      [for server in hcloud_server.k3s_workers: server.id]
    )

    depends_on = [
        hcloud_server.k3s_masters,
        hcloud_server.k3s_workers
    ]
}

