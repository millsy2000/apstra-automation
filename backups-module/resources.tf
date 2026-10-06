## Create an IPv4 resource pool according to the instructions in the lab guide.
resource "apstra_ipv4_pool" "lab_guide" {
  name = "apstra-pool"
  subnets = [
    { network = "4.0.0.0/24" },
    { network = "4.0.1.0/24" },
  ]
}

## Create an IPv4 resource pool for blue VRF
resource "apstra_ipv4_pool" "blue_pool" {
  name = "apstra-pool-blue"
  subnets = [
    { network = "4.0.2.0/24" },
  ]
}

# Create an ASN resource pool according to the instructions in the lab guide.
resource "apstra_asn_pool" "lab_guide" {
  name = "vpod-evpn-asn-pool"
  ranges = [
    {
      first = 100
      last  = 1000
    }
  ]
}

# Create a VNI resource pool according to the instructions in the lab guide.
resource "apstra_vni_pool" "lab_guide" {
  name = "evpn-vni"
  ranges = [
    {
      first = 5000
      last  = 5500
    }
  ]
}

# Create a VNI resource pool according to the instructions in the lab guide.
resource "apstra_vni_pool" "evpn_pool" {
  name = "evpn-vni1"
  ranges = [
    {
      first = 5501
      last  = 6000
    }
  ]
}
