module "stack" {
  source   = "./modules/server-stack"
  for_each = var.servers

  name                 = each.key
  server_type          = each.value.server_type
  location             = each.value.location
  labels               = each.value.labels
  domain               = var.domain
  cloudflare_zone_id   = var.cloudflare_zone_id
  onepassword_vault_id = var.onepassword_vault_id
  create_a             = each.value.dns.create_a
  create_aaaa          = each.value.dns.create_aaaa
  extra_dns_records    = each.value.dns.extra
}
