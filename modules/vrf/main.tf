resource "apstra_datacenter_routing_zone" "vrf" {
  blueprint_id = var.blueprint_id
  name         = var.vrf_name
}
