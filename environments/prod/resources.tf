## Create an IPv4 resource pool according to the instructions in the lab guide.
resource "apstra_ipv4_pool" "prod_ipv4_pool" {
  name = "prod-apstra-pool"
  subnets = [
    { network = "5.0.0.0/24" },
    { network = "5.0.1.0/24" },
  ]
}

## Create an IPv4 resource pool for blue VRF
resource "apstra_ipv4_pool" "prod_blue_pool" {
  name = "prod-apstra-pool-blue"
  subnets = [
    { network = "5.0.2.0/24" },
  ]
}

# Create an ASN resource pool according to the instructions in the lab guide.
resource "apstra_asn_pool" "prod_asn_pool" {
  name = "prod-vpod-evpn-asn-pool"
  ranges = [
    {
      first = 1001
      last  = 2000
    }
  ]
}

# Create a VNI resource pool according to the instructions in the lab guide.
resource "apstra_vni_pool" "prod_evpn_pool" {
  name = "prod-evpn-vni"
  ranges = [
    {
      first = 5501
      last  = 6000
    }
  ]
}
