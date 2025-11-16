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
variable "tld_labs_zone" {
  sensitive = true
}
variable "tld_zen_zone" {
  sensitive = true
}
variable "tld_av_zone" {
  sensitive = true
}
variable "labs_dkim" {
  sensitive = true
}
variable "zen_dkim" {
  sensitive = true
}
variable "av_dkim" {
  sensitive = true
}
variable "labs_apple_domain" {
  sensitive = true
}
variable "zen_apple_domain" {
  sensitive = true
}
variable "av_apple_domain" {
  sensitive = true
}

# Defining Data for the Server deployments
data hcloud_ssh_key "by_fingerprint" {
  fingerprint = var.ssh_token
}

# Defining the DNS Zone - use if you want to create the zone via terraform
resource "hcloud_zone" "lab_zone" {
  name = var.tld_labs_zone
  mode = "primary"
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
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
    rule {
    direction = "out"
    protocol  = "udp"
    port      = "any"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Defining the servers to be created
resource "hcloud_server" "ansible" {
  name        = "ansible"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.by_fingerprint.id]
  firewall_ids = [hcloud_firewall.ansible_firewall.id]
}

# Defining DNS Records
resource "hcloud_zone_rrset" "ansible" {
  zone = var.tld_zen_zone #hcloud_zone.primary_zone.name - use if you want to create the zone via terraform
  name = "ansible"
  type = "A"

  ttl = 3600

  records = [
    { value = hcloud_server.ansible.ipv4_address, comment = "Ansible Server" },
  ]

  change_protection = false
}

# Defining DNS Records for Apple Mail on lab zone
resource "hcloud_zone_rrset" "labs_mx" {
  zone = hcloud_zone.lab_zone.name
  name = "@"
  type = "MX"

  records = [
    { value = "10 mx01.mail.icloud.com.", comment = "Apple Mail" },
    { value = "10 mx02.mail.icloud.com.", comment = "Apple Mail" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "labs_dkim" {
  zone = hcloud_zone.lab_zone.name
  name = "sig1._domainkey"
  type = "CNAME"

  records = [
    { value = var.labs_dkim, comment = "Apple Mail" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "labs_txt" {
  zone = hcloud_zone.lab_zone.name
  name = "@"
  type = "TXT"

  records = [
    { value = provider::hcloud::txt_record("v=spf1 include:icloud.com ~all"), comment = "Apple Mail" },
    { value = provider::hcloud::txt_record(var.labs_apple_domain), comment = "Apple Mail" },
  ]

  change_protection = false
}