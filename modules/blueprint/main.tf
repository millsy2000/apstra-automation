module "design" {
  source      = "../design"
  environment = var.environment
}

resource "apstra_datacenter_blueprint" "blueprint" {
  name        = var.blueprint_name
  template_id = module.design.template_id
}

locals { asn_roles = toset(["spine_asns", "leaf_asns"]) }
resource "apstra_datacenter_resource_pool_allocation" "fabric_asn" {
  for_each     = local.asn_roles
  blueprint_id = apstra_datacenter_blueprint.blueprint.id
  role         = each.key
  pool_ids     = ["${var.environment}-vpod-evpn-asn-pool"]
}

locals { ipv4_roles = toset(["spine_loopback_ips", "leaf_loopback_ips", "spine_leaf_link_ips"]) }
resource "apstra_datacenter_resource_pool_allocation" "fabric_ipv4" {
  for_each     = local.ipv4_roles
  blueprint_id = apstra_datacenter_blueprint.blueprint.id
  role         = each.key
  pool_ids     = ["${var.environment}-apstra-pool"]
}

data "apstra_interface_map" "lab_interface_map" {
  name = "Juniper_vEX__slicer-7x10-1"
}

resource "apstra_datacenter_device_allocation" "spines" {
  for_each                 = var.switches.spines
  blueprint_id             = apstra_datacenter_blueprint.blueprint.id
  initial_interface_map_id = data.apstra_interface_map.lab_interface_map.id
  node_name                = each.key
  device_key               = each.value
  system_attributes = { deploy_mode = "deploy"
  tags = ["spine"] }
}

resource "apstra_datacenter_device_allocation" "leafs" {
  for_each                 = var.switches.leafs
  blueprint_id             = apstra_datacenter_blueprint.blueprint.id
  initial_interface_map_id = data.apstra_interface_map.lab_interface_map.id
  node_name                = each.key
  device_key               = each.value
  system_attributes = { deploy_mode = "deploy"
  tags = ["leaf"] }
}
