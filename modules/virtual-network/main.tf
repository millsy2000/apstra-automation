data "apstra_datacenter_systems" "leaf_switches" {
  blueprint_id = var.blueprint_id
  filters = [
    {
     tag_ids = ["leaf"]
   }
  ]
}

data "apstra_datacenter_virtual_network_binding_constructor" "leaf_switches" {
  blueprint_id = var.blueprint_id
  switch_ids   = data.apstra_datacenter_systems.leaf_switches.ids
}

resource "apstra_datacenter_virtual_network" "vn" {
  blueprint_id                 = var.blueprint_id
  name                         = "${var.tenant_name}-${var.network_name}"
  type                         = "vxlan"
  vni                          = var.vni
  routing_zone_id              = var.routing_zone_id
  ipv4_connectivity_enabled    = true
  ipv4_virtual_gateway_enabled = true
  ipv4_virtual_gateway         = var.virtual_gateway
  ipv4_subnet                  = var.subnet
  bindings                     = data.apstra_datacenter_virtual_network_binding_constructor.leaf_switches.bindings
}

# 1. Define the Connectivity Template using the Interface-type block
resource "apstra_datacenter_connectivity_template_interface" "connectivity_template" {
  blueprint_id = var.blueprint_id
  name         = "single-${var.tenant_name}-${var.network_name}"
  description  = "Connectivity Template for single Virtual Network endpoint access"

  # Map of 'Virtual Network (Single)' Primitives
  virtual_network_singles = {
    # The map key acts as a local identifier for the primitive node
    "edge_vn_primitive" = {
      virtual_network_id = apstra_datacenter_virtual_network.vn.id
      tagged             = true # Set false for untagged / native access VLAN
    }
  }
}