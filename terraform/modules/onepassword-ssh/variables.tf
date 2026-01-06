variable "vault_id" {
  description = "1password vault id"
  type        = string
}

variable "name" {
  description = "item name"
  type        = string
}

variable "private_key" {
  description = "ssh private key"
  type        = string
  sensitive   = true
}

variable "public_key" {
  description = "ssh public key"
  type        = string
}

variable "server_ip" {
  description = "server ip address"
  type        = string
}

variable "server_fqdn" {
  description = "server fully qualified domain name"
  type        = string
}

