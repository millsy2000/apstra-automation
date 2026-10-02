data "apstra_datacenter_virtual_network_binding_constructor" "all_switches" {
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  switch_ids   = ["krx0ICeT9hwOlysDng", "_TaRB5YRFiaNBWQDgg", "mnyctEQZUH2DnJLLIg"]
}

resource "apstra_datacenter_virtual_network" "test_vn" {
  name                         = "test_vn"
  blueprint_id                 = apstra_datacenter_blueprint.lab_guide.id
  type                         = "vxlan"
  routing_zone_id              = apstra_datacenter_routing_zone.blue.id
  ipv4_connectivity_enabled    = true
  ipv4_virtual_gateway_enabled = true
  ipv4_virtual_gateway         = "192.168.10.1"
  ipv4_subnet                  = "192.168.10.0/24"
  bindings = data.apstra_datacenter_virtual_network_binding_constructor.all_switches.bindings

}

resource "apstra_datacenter_virtual_network" "new_vn" {
  name                         = "new_vn"
  blueprint_id                 = apstra_datacenter_blueprint.lab_guide.id
  type                         = "vxlan"
  routing_zone_id              = apstra_datacenter_routing_zone.blue.id
  ipv4_connectivity_enabled    = true
  ipv4_virtual_gateway_enabled = true
  ipv4_virtual_gateway         = "192.168.20.1"
  ipv4_subnet                  = "192.168.20.0/24"
  bindings = data.apstra_datacenter_virtual_network_binding_constructor.all_switches.bindings

}

