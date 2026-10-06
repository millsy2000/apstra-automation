module "design" {
  source = "../design"
}

resource "apstra_datacenter_blueprint" "blueprint" {
  name        = var.blueprint_name
  template_id = module.design.template_id
}
