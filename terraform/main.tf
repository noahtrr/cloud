# The Terraform Provider Configuration
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

# The Hetzner Cloud provider configuration
provider "hcloud" {
  token = var.hcloud_token
}

# Setting up variables
variable "hcloud_token" {
  sensitive = true
}
variable "ssh_token" {
  sensitive = true
}

# Defining Data for the Server deployments
data hcloud_ssh_key "by_fingerprint" {
  fingerprint = var.ssh_token
}

# Defining the servers to be created
resource "hcloud_server" "ansible" {
  count       = 1
  name        = "ansible"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.by_fingerprint.id] 
}