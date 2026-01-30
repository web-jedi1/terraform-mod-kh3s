resource "hcloud_load_balancer" "load_balancer" {
    name               = "k3s-lb"
    location           = var.cluster_region 
    load_balancer_type = "lb11"
}

resource "hcloud_load_balancer_network" "lb_net" {
    load_balancer_id = hcloud_load_balancer.load_balancer.id
    subnet_id        = hcloud_network_subnet.k3s_worker.id
    ip               = var.lb_internal_ip
}

resource "hcloud_load_balancer_target" "lb_targets" {
    for_each         = hcloud_server.k3s_workers
    load_balancer_id = hcloud_load_balancer.load_balancer.id
    server_id        = each.value.id
    type             = "server"
    use_private_ip   = true
}

resource "hcloud_load_balancer_service" "http" {
    load_balancer_id = hcloud_load_balancer.load_balancer.id
    protocol         = "tcp"
    listen_port      = 80      
    destination_port = 80
    proxyprotocol   = true

    health_check {
        protocol = "tcp"
        port     = 80
        retries  = 5
        interval = 10
        timeout  = 5
    }
}

resource "hcloud_load_balancer_service" "https" {
    load_balancer_id = hcloud_load_balancer.load_balancer.id
    protocol         = "tcp"
    listen_port      = 443        
    destination_port = 443
    proxyprotocol    = true

    health_check {
        protocol = "tcp"
        port     = 443
        retries  = 5
        interval = 10
        timeout  = 5
    }
}

# TODO: Add ability to create DNS records, write own terraform provider?
#       For now just create it manually. 
#       When the time comes, make this into a separate module based on the outputs of this module 
