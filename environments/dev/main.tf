

module "blueprint" {
  source         = "../../modules/blueprint"
  blueprint_name = var.blueprint_name
  environment    = var.environment
}

module "finance" {
  source          = "../../modules/tenant"
  blueprint_id    = module.blueprint.blueprint_id
  tenant_name     = "FINANCE"
  app_vlan        = 100
  app_vni         = 10100
  subnet          = "192.168.20.0/24"
  virtual_gateway = "192.168.20.1"
}

