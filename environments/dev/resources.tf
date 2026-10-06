## Create an IPv4 resource pool according to the instructions in the lab guide.
resource "apstra_ipv4_pool" "dev_ipv4_pool" {
  name = "dev-apstra-pool"
  subnets = [
    { network = "4.0.0.0/24" },
    { network = "4.0.1.0/24" },
  ]
}

## Create an IPv4 resource pool for blue VRF
resource "apstra_ipv4_pool" "dev_blue_pool" {
  name = "dev-apstra-pool-blue"
  subnets = [
    { network = "4.0.2.0/24" },
  ]
}

# Create an ASN resource pool according to the instructions in the lab guide.
resource "apstra_asn_pool" "dev_asn_pool" {
  name = "dev-vpod-evpn-asn-pool"
  ranges = [
    {
      first = 100
      last  = 1000
    }
  ]
}

# Create a VNI resource pool according to the instructions in the lab guide.
resource "apstra_vni_pool" "dev_evpn_pool" {
  name = "dev-evpn-vni"
  ranges = [
    {
      first = 5000
      last  = 5500
    }
  ]
}
