# The Terraform Provider Configuration
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.56.0"
    }
  }
}

# The Hetzner Cloud provider configuration
provider "hcloud" {
  token = var.hcloud_token
}

# Defining the DNS Zone - use if you want to create the zone via terraform
resource "hcloud_zone" "lab_zone" {
  name = var.tld_labs_zone
  mode = "primary"
}
resource "hcloud_zone" "zen_zone" {
  name = var.tld_zen_zone
  mode = "primary"
}
resource "hcloud_zone" "av_zone" {
  name = var.tld_av_zone
  mode = "primary"
}

# Define DNS Records for SKRIME Server
resource "hcloud_zone_rrset" "labs_skrime_dash" {
  zone = hcloud_zone.lab_zone.name
  name = "dash"
  type = "A"

  records = [
    { value = "77.90.15.177", comment = "SKRIME Server" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "labs_skrime_traefik" {
  zone = hcloud_zone.lab_zone.name
  name = "traefik"
  type = "A"

  records = [
    { value = "77.90.15.177", comment = "SKRIME Server" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "labs_skrime_pocketid" {
  zone = hcloud_zone.lab_zone.name
  name = "id"
  type = "A"

  records = [
    { value = "77.90.15.177", comment = "SKRIME Server" },
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

# Defining DNS Records for Apple Mail on zen zone
resource "hcloud_zone_rrset" "zen_mx" {
  zone = hcloud_zone.zen_zone.name
  name = "@"
  type = "MX"

  records = [
    { value = "10 mx01.mail.icloud.com.", comment = "Apple Mail" },
    { value = "10 mx02.mail.icloud.com.", comment = "Apple Mail" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "zen_dkim" {
  zone = hcloud_zone.zen_zone.name
  name = "sig1._domainkey"
  type = "CNAME"

  records = [
    { value = var.zen_dkim, comment = "Apple Mail" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "zen_txt" {
  zone = hcloud_zone.zen_zone.name
  name = "@"
  type = "TXT"

  records = [
    { value = provider::hcloud::txt_record("v=spf1 include:icloud.com ~all"), comment = "Apple Mail" },
    { value = provider::hcloud::txt_record(var.zen_apple_domain), comment = "Apple Mail" },
  ]

  change_protection = false
}

# Defining DNS Records for Apple Mail on av zone
resource "hcloud_zone_rrset" "av_mx" {
  zone = hcloud_zone.av_zone.name
  name = "@"
  type = "MX"

  records = [
    { value = "10 mx01.mail.icloud.com.", comment = "Apple Mail" },
    { value = "10 mx02.mail.icloud.com.", comment = "Apple Mail" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "av_dkim" {
  zone = hcloud_zone.av_zone.name
  name = "sig1._domainkey"
  type = "CNAME"

  records = [
    { value = var.av_dkim, comment = "Apple Mail" },
  ]

  change_protection = false
}
resource "hcloud_zone_rrset" "av_txt" {
  zone = hcloud_zone.av_zone.name
  name = "@"
  type = "TXT"

  records = [
    { value = provider::hcloud::txt_record("v=spf1 include:icloud.com ~all"), comment = "Apple Mail" },
    { value = provider::hcloud::txt_record(var.av_apple_domain), comment = "Apple Mail" },
  ]

  change_protection = false
}