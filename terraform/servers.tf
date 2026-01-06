module "stack" {
  source   = "./modules/server-stack"
  for_each = local.servers

  name                 = each.key
  server_type          = each.value.server_type
  location             = lookup(each.value, "location", local.default_location)
  labels               = lookup(each.value, "labels", {})
  domain               = local.domain
  cloudflare_zone_id   = var.cloudflare_zone_id
  onepassword_vault_id = var.onepassword_vault_id
  create_a             = lookup(lookup(each.value, "dns", {}), "create_a", true)
  create_aaaa          = lookup(lookup(each.value, "dns", {}), "create_aaaa", true)
  extra_dns_records    = lookup(lookup(each.value, "dns", {}), "extra", [])
}
