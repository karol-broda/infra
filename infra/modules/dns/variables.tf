variable "zone_id" {
  description = "cloudflare zone id"
  type        = string
}

variable "name" {
  description = "record name (subdomain)"
  type        = string
}

variable "domain" {
  description = "base domain"
  type        = string
}

variable "create_a" {
  description = "whether to create an A record"
  type        = bool
  default     = true
}

variable "create_aaaa" {
  description = "whether to create an AAAA record"
  type        = bool
  default     = true
}

variable "ipv4" {
  description = "ipv4 address for A record"
  type        = string
  default     = null
}

variable "ipv6" {
  description = "ipv6 address for AAAA record"
  type        = string
  default     = null
}

variable "extra_records" {
  description = "additional dns records"
  type = list(object({
    name    = string
    type    = string
    content = optional(string)
    data    = optional(map(any))
    ttl     = optional(number, 300)
    proxied = optional(bool, false)
  }))
  default = []
}
