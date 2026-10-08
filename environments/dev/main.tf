
module "blueprint" {
  source         = "../../modules/blueprint"
  blueprint_name = var.blueprint_name
  environment    = var.environment
  ipv4_pool      = apstra_ipv4_pool.dev_ipv4_pool.id
  asn_pool       = apstra_asn_pool.dev_asn_pool.id
  evpn_pool      = apstra_vni_pool.dev_evpn_pool.id

  switches        = {
    spines = {
      spine1 = "525400AAD295" // 172.20.169.11
      spine2 = "5254005ED453" // 172.20.169.12
    }
    leafs = {
      apstra_esi_001_leaf1    = "525400C6A020" // 172.20.169.13
      apstra_esi_001_leaf2    = "5254001675CC" // 172.20.169.15
      apstra_single_001_leaf1 = "525400DA9B72" // 172.20.169.14
    }
  }
}

module "finance" {
  source          = "../../modules/tenant"
  blueprint_id    = module.blueprint.blueprint_id
  tenant_name     = "FIN-TEST"
  app_vlan        = 100
  app_vni         = 10100
  subnet          = "192.168.20.0/24"
  virtual_gateway = "192.168.20.1"
}

