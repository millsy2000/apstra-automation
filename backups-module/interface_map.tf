locals {
  # local.if_map spells out two ranges of mappings for our
  # second interface map: 48x10G ports and 6x40G ports.
  if_map = [
    { // map logical 1/1 - 1/7 to physical ge-0/0/0 - ge-0/0/6
      ld_panel       = 1
      ld_first_port  = 1
      phy_prefix     = "ge-0/0/"
      phy_first_port = 0
      count          = 7
    },
  ]
  # local.interfaces loops over the elements of if_map
  # (panel 1 and panel 2).
  # within each iteration, it loops 'count' times
  # (every interface in the panel)
  # to build up the detailed mapping between logical and physical ports.
  interfaces = [
    for map in local.if_map : [
      for i in range(map.count) : {
        logical_device_port     = format("%d/%d", map.ld_panel, map.ld_first_port + i)
        physical_interface_name = format("%s%d", map.phy_prefix, map.phy_first_port + i)
      }
    ]
  ]
}

# second example: interface mappings are calculated
# using the local variables above.
resource "apstra_interface_map" "with_loops" {
  name              = "Juniper_vEX__slicer-7x10-1-Terraform"
  logical_device_id = "slicer-7x10-1"
  device_profile_id = "Juniper_vEX"
  interfaces        = flatten([local.interfaces])
}
