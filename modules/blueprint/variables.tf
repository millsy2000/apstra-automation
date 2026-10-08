variable "blueprint_name" {
  description = "Name of Blueprint"
  type        = string
}

variable "environment" {
  type = string
}

variable "switches" {
  type = map
}

variable "asn_pool" {
  type = string
}

variable "ipv4_pool" {
  type = string
}

variable "evpn_pool" {
  type = string
}