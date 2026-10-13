resource "apstra_datacenter_routing_zone" "vrf" {
  blueprint_id = var.blueprint_id
  name         = var.vrf_name
}

resource "apstra_ipv4_pool" "leaf_loopback_ips" {
  name = "${var.vrf_name}-ipv4-pool"
  subnets = [
    { network = var.loopbacks },
  ]
}

resource "apstra_datacenter_resource_pool_allocation" "leaf_looopback_allocation" {
  blueprint_id    = var.blueprint_id
  routing_zone_id = apstra_datacenter_routing_zone.vrf.id
  pool_ids        = [apstra_ipv4_pool.leaf_loopback_ips.id]
  role            = "leaf_loopback_ips"
}