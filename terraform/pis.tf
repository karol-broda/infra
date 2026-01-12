locals {
  pis = ["hytale-kiosk"]
}

data "local_file" "pi_age_keys" {
  for_each = toset(local.pis)
  filename = "${path.root}/../keys/age/${each.key}.txt"
}

module "pi_secrets" {
  source   = "./modules/pi-secrets"
  for_each = toset(local.pis)

  vault_id     = var.onepassword_vault_id
  name         = each.key
  age_key_file = data.local_file.pi_age_keys[each.key].content
}
