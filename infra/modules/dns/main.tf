resource "cloudflare_dns_record" "a" {
  count = var.create_a ? 1 : 0

  zone_id = var.zone_id
  name    = var.name
  content = var.ipv4
  type    = "A"
  ttl     = 300
  proxied = false

  lifecycle {
    ignore_changes = [name, meta, proxiable, settings, tags]
  }
}

resource "cloudflare_dns_record" "aaaa" {
  count = var.create_aaaa ? 1 : 0

  zone_id = var.zone_id
  name    = var.name
  content = var.ipv6
  type    = "AAAA"
  ttl     = 300
  proxied = false

  lifecycle {
    ignore_changes = [name, meta, proxiable, settings, tags]
  }
}

resource "cloudflare_dns_record" "extra" {
  for_each = { for idx, r in var.extra_records : "${r.name}-${r.type}" => r }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  proxied = each.value.proxied
  content = each.value.content
  data    = each.value.data

  lifecycle {
    ignore_changes = [name, meta, proxiable, settings, tags, content, priority]
  }
}
