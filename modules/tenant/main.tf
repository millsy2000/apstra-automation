module "vrf" {
  source       = "../vrf"
  blueprint_id = var.blueprint_id
  vrf_name     = var.tenant_name
}

module "app_network" {
   for_each = {
    for network in var.networks :
    network.name => network
  }

  source = "../virtual-network"
  blueprint_id = var.blueprint_id
  routing_zone_id = module.vrf.routing_zone_id
  tenant_name = each.value.name
  vlan_id = each.value.app_vlan
  vni = each.value.app_vni
  subnet = each.value.subnet
  virtual_gateway = each.value.virtual_gateway
}
