locals {
  switches = {
     spines = {
        spine1                  =  "5254008F72C2" // 172.20.127.11
        spine2                  =  "525400024E2C" // 172.20.127.12
    }
      leafs = {
        apstra_esi_001_leaf1    =  "525400150651" // 172.20.127.13
        apstra_esi_001_leaf2    =  "52540058E951" // 172.20.127.15
        apstra_single_001_leaf1 =  "5254005E993B" // 172.20.127.14
    }
  }
}

# https://cloudlabs.apstra.com/labguide/Cloudlabs/4.1.2/lab1-junos/lab1-junos-6_blueprints_.html

# Instantiate a blueprint from the previously-created template
resource "apstra_datacenter_blueprint" "lab_guide" {
  name        = "apstra-pod1"
  template_id = apstra_template_rack_based.lab_guide.id
}

# Assign previously-created ASN resource pools to roles in the fabric
locals { asn_roles = toset(["spine_asns", "leaf_asns"]) }
resource "apstra_datacenter_resource_pool_allocation" "lab_guide_asn" {
  for_each     = local.asn_roles
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  role         = each.key
  pool_ids     = [apstra_asn_pool.lab_guide.id]
}

# Assign previously-created IPv4 resource pools to roles in the fabric
locals { ipv4_roles = toset(["spine_loopback_ips", "leaf_loopback_ips", "spine_leaf_link_ips"]) }
resource "apstra_datacenter_resource_pool_allocation" "lab_guide_ipv4" {
  for_each     = local.ipv4_roles
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  role         = each.key
  pool_ids     = [apstra_ipv4_pool.lab_guide.id]
}

resource "apstra_datacenter_resource_pool_allocation" "blue_evpn" {
  blueprint_id    = apstra_datacenter_blueprint.lab_guide.id
#  routing_zone_id = apstra_datacenter_routing_zone.blue.id
  pool_ids        = [apstra_vni_pool.evpn_pool.id]
  role            = "evpn_l3_vnis"
}

resource "apstra_datacenter_resource_pool_allocation" "vni_vn_ids" {
  blueprint_id    = apstra_datacenter_blueprint.lab_guide.id
  pool_ids        = [apstra_vni_pool.evpn_pool.id]
  role            = "vni_virtual_network_ids"
}

# Next, assign an IPv4 pool to be used by loopback interfaces of leaf
# switches participating in the Routing Zone.
resource "apstra_datacenter_resource_pool_allocation" "blue_loopbacks" {
  blueprint_id    = apstra_datacenter_blueprint.lab_guide.id
  routing_zone_id = apstra_datacenter_routing_zone.blue.id
  pool_ids        = [apstra_ipv4_pool.blue_pool.id]
  role            = "leaf_loopback_ips"
}

# Discover details (we need the ID) of an interface map using the name supplied
# in the lab guide.
data "apstra_interface_map" "lab_guide" {
  name = "Juniper_vEX__slicer-7x10-1"
}

# Assign interface map and system IDs using the map we created earlier
resource "apstra_datacenter_device_allocation" "spines" {
  for_each         = local.switches.spines
  blueprint_id     = apstra_datacenter_blueprint.lab_guide.id
  initial_interface_map_id = data.apstra_interface_map.lab_guide.id
  node_name        = each.key
  device_key       = each.value
  system_attributes = { deploy_mode = "deploy" 
                        tags = ["spine"] }
}

# Assign interface map and system IDs using the map we created earlier
resource "apstra_datacenter_device_allocation" "leafs" {
  for_each         = local.switches.leafs
  blueprint_id     = apstra_datacenter_blueprint.lab_guide.id
  initial_interface_map_id = data.apstra_interface_map.lab_guide.id
  node_name        = each.key
  device_key       = each.value
  system_attributes = { deploy_mode = "deploy"
                        tags = ["leaf"] }
}

# Deploy the blueprint.
#resource "apstra_blueprint_deployment" "lab_guide" {
#  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
#  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
#  depends_on = [
    # Lots of terraform happens in parallel -- this section forces deployment
    # to wait until resources which modify the blueprint are complete.
#    apstra_datacenter_device_allocation.spines,
#    apstra_datacenter_device_allocation.leafs,
#    apstra_datacenter_resource_pool_allocation.lab_guide_asn,
#    apstra_datacenter_resource_pool_allocation.lab_guide_ipv4,
#    apstra_datacenter_resource_pool_allocation.blue_evpn,
#    apstra_datacenter_resource_pool_allocation.blue_loopbacks,
#    apstra_datacenter_resource_pool_allocation.vni_vn_ids,
#  ]
#}
