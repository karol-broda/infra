resource "cloudflare_dns_record" "atproto_identity" {
  zone_id = var.cloudflare_zone_id
  name    = "_atproto.${var.domain}"
  type    = "TXT"
  content = "did=did:plc:2i4pifeh2mhzap63meo6t7lq"
  ttl     = 300
}
