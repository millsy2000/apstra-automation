module "design" {
  source      = "../design"
  environment = var.environment
}

resource "apstra_datacenter_blueprint" "blueprint" {
  name        = var.blueprint_name
  template_id = module.design.template_id
}
