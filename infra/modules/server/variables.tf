variable "name" {
  description = "server hostname"
  type        = string
}

variable "server_type" {
  description = "hetzner server type"
  type        = string
}

variable "location" {
  description = "hetzner datacenter location"
  type        = string
}

variable "labels" {
  description = "server labels"
  type        = map(string)
  default     = {}
}

