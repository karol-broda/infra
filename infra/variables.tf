variable "state_passphrase" {
  type      = string
  sensitive = true
}

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

variable "domain" {
  type = string
}

variable "servers" {
  type = map(object({
    server_type = string
    location    = string
    labels      = map(string)
    dns = object({
      create_a    = optional(bool, true)
      create_aaaa = optional(bool, true)
      extra = list(object({
        name    = string
        type    = string
        content = optional(string)
        data    = optional(map(any))
        ttl     = optional(number, 300)
        proxied = optional(bool, false)
      }))
    })
  }))
}
