
module "blueprint" {
  source         = "../../modules/blueprint"
  blueprint_name = var.blueprint_name
  environment    = var.environment
  ipv4_pool      = apstra_ipv4_pool.dev_ipv4_pool.id
  asn_pool       = apstra_asn_pool.dev_asn_pool.id
  evpn_pool      = apstra_vni_pool.dev_evpn_pool.id

  switches        = {
    spines = {
      spine1 = "5254005A94A2" // 172.20.13.11
      spine2 = "52540015A413" // 172.20.13.12
    }
    leafs = {
      apstra_esi_001_leaf1    = "525400630E34" // 172.20.13.13
      apstra_esi_001_leaf2    = "525400C8F581" // 172.20.13.15
      apstra_single_001_leaf1 = "525400F8E66D" // 172.20.13.14
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



#module "finance" {
#  source          = "../../modules/tenant"
#  blueprint_id    = module.blueprint.blueprint_id
#  tenant_name     = "FIN-TEST"
#  networks = [
#    {
#    name            = "finance-1"
#    app_vlan        = 100
#    app_vni         = 10100
#    subnet          = "192.168.21.0/24"
#    virtual_gateway = "192.168.21.1"
#    }
#  ]
#}
#
#module "HR" {
#  source          = "../../modules/tenant"
#  blueprint_id    = module.blueprint.blueprint_id
#  tenant_name     = "HR"
#  networks = [
#  {
#    name            = "HR-1"
#    app_vlan        = 200
#    app_vni         = 10200
#    subnet          = "192.168.22.0/24"
#    virtual_gateway = "192.168.22.1"
#  },
#  {
#    name            = "HR-2"
#    app_vlan        = 300
#    app_vni         = 10300
#    subnet          = "192.168.23.0/24"
#    virtual_gateway = "192.168.23.1"
#  }
#]
#}

