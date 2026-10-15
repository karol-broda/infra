output "ipv4" {
  value = hcloud_server.this.ipv4_address
}

output "ipv6" {
  value = hcloud_server.this.ipv6_address
}

output "id" {
  value = hcloud_server.this.id
}

output "ssh_private_key" {
  value     = tls_private_key.this.private_key_openssh
  sensitive = true
}

output "ssh_public_key" {
  value = tls_private_key.this.public_key_openssh
}

