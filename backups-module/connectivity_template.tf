
# 1. Define the Connectivity Template using the Interface-type block
resource "apstra_datacenter_connectivity_template_interface" "new_vn_ct" {
  blueprint_id = var.blueprint_id
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
  blueprint_id = var.blueprint_id
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
