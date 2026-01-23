# terraform-mod-kh3s


<br>

Terraform module to instantiate k3s clusters on hetzner cloud. 

## Usage

Variables need to be initialized, this can be done in a `variables.tf` file at the root of the project importing the module.
```hcl

variable "hcloud_token" {
    type      = string
    sensitive = true
}

variable "flux_git_token" { type = string }
variable "flux_git_url"   { type = string }
```

A basic example of instantiating the module can be seen below. This instantiates a single master and worker in the `hel1` region, of type `cax21`. It keeps flux disabled.
```hcl
module "k3s_cluster" {
    source = "./terraform-mod-kh3s"

    hcloud_token   = var.hcloud_token
    flux_git_token = var.flux_git_token
    flux_git_url   = var.flux_git_url

    bootstrap_kubernetes = true
    bootstrap_flux       = false

    cluster_region     = "hel1"
    master_count       = 1
    worker_count       = 1 
    master_server_type = "cax21"
    worker_server_type = "cax21"
}
```

A more complex example can be seen below. In this instance, nodes are defined explicitely to allow for granular control of the cluster. Flux is enabled to enable GitOps.
```hcl

```

---