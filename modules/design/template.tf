# Create a template using previously looked-up (data) spine info and previously
# created (resource) rack types.
resource "apstra_template_rack_based" "rack_template" {
  name                     = "apstra_junos"
  asn_allocation_scheme    = "unique"
  overlay_control_protocol = "evpn"
  spine = {
    count             = 2
    logical_device_id = data.apstra_design_logical_device.terraform_switch.id
  }
  rack_infos = {
    (apstra_rack_type.terraform_esi.id)    = { count = 1 }
    (apstra_rack_type.terraform_single.id) = { count = 1 }
  }
}
