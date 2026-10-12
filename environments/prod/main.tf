
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

locals {
  # Load the full YAML file as a map
  tenants = yamldecode(file("tenants.yaml"))
}

module "tenant" {
  for_each        =  {
        for tenant in local.tenants.tenants:
          tenant.tenant_name => tenant
  }
  source          = "../../modules/tenant"
  blueprint_id    = module.blueprint.blueprint_id

  networks = each.value.networks
  tenant_name = each.value.tenant_name
}

