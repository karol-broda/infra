variable "vault_id" {
  type = string
}

variable "name" {
  type = string
}

variable "age_key_file" {
  type      = string
  sensitive = true
}
