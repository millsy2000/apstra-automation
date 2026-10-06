module "vrf" {
  source       = "../vrf"
  blueprint_id = var.blueprint_id
  vrf_name     = var.tenant_name
}

module "app_network" {
  source          = "../virtual-network"
  blueprint_id    = var.blueprint_id
  routing_zone_id = module.vrf.routing_zone_id
  tenant_name     = "${var.tenant_name}-APP"
  vlan_id         = var.app_vlan
  vni             = var.app_vni
  virtual_gateway = var.virtual_gateway
  subnet          = var.subnet
}
