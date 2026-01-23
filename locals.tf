locals {
    generated_master_nodes = {
        for i in range(1, var.master_count+1):
        "k3s-master-${i}" => {
            hostname       = "k3s-master-${i}"
            ip             = cidrhost(var.subnet_k3s_master_cidr, i)
            server_type    = var.master_server_type
            classification = "master"
            environment    = var.environment
            workload       = "control-plane"
        }
   }

    generated_worker_nodes = {
        for i in range(1, var.worker_count+1):
        "k3s-worker-${i}" => {
            hostname       = "k3s-worker-${i}"
            ip             = cidrhost(var.subnet_k3s_worker_cidr, 10 + i) # maintain 10 free ips for other services e.g. ingress.
            server_type    = var.worker_server_type
            classification = "worker"
            environment    = var.environment
            workload       = "general"
        }
    } 

    server_k3s_master_node_definitions = var.custom_master_nodes != null ? var.custom_master_nodes : local.generated_master_nodes
    server_k3s_worker_node_definitions = var.custom_worker_nodes != null ? var.custom_worker_nodes : local.generated_worker_nodes
}
