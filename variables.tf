
# PROVIDER
variable "hcloud_token" {
    type        = string
    sensitive   = true
    description = "hetzner api token"
}

# MODULE
variable "bootstrap_kubernetes" {
    type        = bool
    default     = false
    description = "run ansible k3s bootstrap"
}

variable "bootstrap_flux" {
    type        = bool
    default     = false
    description = "bootstrap flux service on cluster"
}

# CLUSTER
variable "vpc_master_subnet" {
    type        = string
    default     = "10.0.0.0/16"
    description = "VPC Master Subnet"
}

variable "subnet_k3s_master_cidr" {
    type        = string
    default     = "10.0.1.0/24"
    description = "K3S Master Subnet"
}

variable "subnet_k3s_worker_cidr" {
    type        = string
    default     = "10.0.2.0/24"
    description = "K3S Worker Subnet"
}

variable "cluster_region" {
    type        = string
    default     = "hel1"
    description = "Hetzner region where the cluster is based"
}

variable "environment" {
  type    = string
  default = "development"
}

variable "k3s_os_image" {
    type        = string
    default     = "debian-12"
    description = "OS Image"
}

variable "master_count" {
    type        = number
    default     = 1
    description = "master count"
}

variable "worker_count" {
    type        = number
    default     = 1
    description = "worker count"
}

variable "master_server_type" {
    type        = string
    default     = "cax21"
    description = "master server type"
}

variable "worker_server_type" {
    type        = string
    default     = "cax21"
    description = "worker server type"
}

variable "workload" {
    type        = string
    default     = "general"
    description = "Default workload type"
}

variable "custom_master_nodes" {
    type = map(object({
        hostname       = string
        ip             = string
        server_type    = string
        classification = string
        environment    = string
        workload       = string
    }))
    default = null
    description = "Custom master node definitions (overrides count-based generation)"
}

variable "custom_worker_nodes" {
    type = map(object({
        hostname       = string
        ip             = string
        server_type    = string
        classification = string
        environment    = string
        workload       = string
    }))
    default = null
    description = "Custom worker node definitions (overrides count-based generation)"
}

variable "lb_internal_ip" {
    type    = string
    default = "10.0.2.1"
}

variable "k3s_user_name_service" {
    type        = string
    default     = "k3s"
    description = "Default User Name Service"
}

variable "k3s_user_name_ansible" {
    type        = string
    default     = "svc-ansible"
    description = "Default User Name Ansible"
}

variable "flux_git_token" {
    type        = string
    sensitive   = false # not in output anyways, and ansible output gets supressed which makes debug difficult
    description = "Git PAT for repo monitored by flux (read only)"
}

variable "flux_git_url" {
    type        = string
    sensitive   = false
    description = "Git Project URL"
}

# OUTPUTS
variable "cert_out_dir" {
    type        = string
    default     = "cert"
    description = "Default directory for placing generated tf key material, relative to tf dir"
}
