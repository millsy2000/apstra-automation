
# 1. Define the Connectivity Template using the Interface-type block
resource "apstra_datacenter_connectivity_template_interface" "new_vn_ct" {
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  name         = "New_CT_Endpoint_Connectivity"
  description  = "Connectivity Template for single Virtual Network endpoint access"

  # Map of 'Virtual Network (Single)' Primitives
  virtual_network_singles = {
    # The map key acts as a local identifier for the primitive node
    "edge_vn_primitive" = {
      virtual_network_id = apstra_datacenter_virtual_network.new_vn.id
      tagged             = true # Set false for untagged / native access VLAN
    }
  }
}


# 1. Define the Connectivity Template using the Interface-type block
resource "apstra_datacenter_connectivity_template_interface" "test_vn_ct" {
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  name         = "Test_CT_Endpoint_Connectivity"
  description  = "Connectivity Template for single Virtual Network endpoint access"

  # Map of 'Virtual Network (Single)' Primitives
  virtual_network_singles = {
    # The map key acts as a local identifier for the primitive node
    "edge_vn_primitive" = {
      virtual_network_id = apstra_datacenter_virtual_network.test_vn.id
      tagged             = true # Set false for untagged / native access VLAN
    }
  }
}

locals { leafs = toset(["krx0ICeT9hwOlysDng", "_TaRB5YRFiaNBWQDgg"]) }
# Look up all interfaces belonging to a specific switch
data "apstra_datacenter_interfaces_by_system" "leaf_ports" {
  for_each     = local.leafs
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  system_id    = each.value # System label or ID as assigned in the blueprint
}


# The data source returns a map of interface names to graph node IDs
resource "apstra_datacenter_connectivity_templates_assignment" "endpoint_attachment" {
  for_each             = data.apstra_datacenter_interfaces_by_system.leaf_ports
  blueprint_id         = apstra_datacenter_blueprint.lab_guide.id
  application_point_id = each.value.if_map["ge-0/0/3"]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template_interface.new_vn_ct.id, apstra_datacenter_connectivity_template_interface.test_vn_ct.id
  ]
}

# 1. Query all interface graph IDs matching the specific link tag
data "apstra_datacenter_systems" "leaf_switches" {
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  filters      = [{ tag_ids = ["leaf"] }] # The tag assigned to switch ports in the blueprint
}

# 2. Look up all interfaces belonging to matched switches
data "apstra_datacenter_interfaces_by_system" "leaf_ports_tags" {
  for_each     = toset(data.apstra_datacenter_systems.leaf_switches.ids)
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  system_id    = each.value
}


## The data source returns a map of interface names to graph node IDs
#resource "apstra_datacenter_connectivity_templates_assignment" "endpoint_attachment_tag" {
#  for_each                  = data.apstra_datacenter_interfaces_by_system.leaf_ports_tags
#  blueprint_id              = apstra_datacenter_blueprint.lab_guide.id
#  application_point_id      = each.value.if_map["ge-0/0/3"]
#  connectivity_template_ids = [
#    apstra_datacenter_connectivity_template_interface.new_vn_ct.id, apstra_datacenter_connectivity_template_interface.test_vn_ct.id
#  ]
#}
