resource "apstra_datacenter_virtual_network" "vn" {
  blueprint_id                 = var.blueprint_id
  name                         = var.tenant_name
  type                         = "vxlan"
  vni                          = var.vni
  routing_zone_id              = var.routing_zone_id
  ipv4_connectivity_enabled    = true
  ipv4_virtual_gateway_enabled = true
  ipv4_virtual_gateway         = var.virtual_gateway
  ipv4_subnet                  = var.subnet
}
