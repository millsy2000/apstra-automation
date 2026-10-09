
module "blueprint" {
  source         = "../../modules/blueprint"
  blueprint_name = var.blueprint_name
  environment    = var.environment
  ipv4_pool      = apstra_ipv4_pool.prod_ipv4_pool.id
  asn_pool       = apstra_asn_pool.prod_asn_pool.id
  evpn_pool      = apstra_vni_pool.prod_evpn_pool.id

  switches        = {
    spines = {
      spine1 = "" // .11
      spine2 = "" // .12
    }
    leafs = {
      apstra_esi_001_leaf1    = "" // .13
      apstra_esi_001_leaf2    = "" // .15
      apstra_single_001_leaf1 = "" // .14
    }
  }
}

module "finance" {
  source          = "../../modules/tenant"
  blueprint_id    = module.blueprint.blueprint_id
  tenant_name     = "FIN-TEST"
  networks = [
    {
    name            = "finance-1"
    app_vlan        = 100
    app_vni         = 10100
    subnet          = "192.168.21.0/24"
    virtual_gateway = "192.168.21.1"
    }
  ]
}

module "HR" {
  source          = "../../modules/tenant"
  blueprint_id    = module.blueprint.blueprint_id
  tenant_name     = "HR"
  networks = [
  {
    name            = "HR-1"
    app_vlan        = 200
    app_vni         = 10200
    subnet          = "192.168.22.0/24"
    virtual_gateway = "192.168.22.1"
  },
  {
    name            = "HR-2"
    app_vlan        = 300
    app_vni         = 10300
    subnet          = "192.168.23.0/24"
    virtual_gateway = "192.168.23.1"
  }
]
}

