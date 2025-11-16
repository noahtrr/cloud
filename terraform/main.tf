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

# Defining the firewall to be created
resource "hcloud_firewall" "ansible_firewall" {
  name = "ansibleFW"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "any"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
    rule {
    direction = "out"
    protocol  = "udp"
    port      = "any"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Defining the servers to be created
resource "hcloud_server" "ansible" {
  count       = 1
  name        = "ansible"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.by_fingerprint.id]
  firewall_ids = [hcloud_firewall.ansible_firewall.id]
}