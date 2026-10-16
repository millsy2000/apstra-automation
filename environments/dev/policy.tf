resource "apstra_datacenter_security_policy" "from_DB-HR" {
  blueprint_id                     = "295180f4-42e6-4f37-bfce-bb309065ba5e"
  name                             = "Block traffic from DB HR"
  description                      = "Block all traffic"
  ip_version                       = "ipv4"
  source_application_point_id      = "hfEZqz7L0ZtDdgOaBw"
  destination_application_point_id = "UElnwqWVaLQYJHa0sw"
  rules = [
    {
      name        = "deny_all_ip"
      action      = "deny_log"
      protocol    = "ip"
    },
  ]
}