variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "onepassword_account" {
  type = string
}

variable "onepassword_vault_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}
