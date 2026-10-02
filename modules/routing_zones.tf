# This example creates a routing zone within an
# existing datacenter blueprint.
resource "apstra_datacenter_routing_zone" "blue" {
  name         = "vrf_blue"
  blueprint_id = var.blueprint_id
  dhcp_servers = ["192.168.100.10", "192.168.200.10"] # optional
  #  routing_policy_id = "<routing-policy-node-id-goes-here>" # optional
}

