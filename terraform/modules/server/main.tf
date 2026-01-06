resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "this" {
  name       = "${var.name}-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "hcloud_server" "this" {
  name        = var.name
  image       = "debian-12"
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.this.id]

  labels = merge({ managed = "terraform" }, var.labels)

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.this.private_key_openssh
  filename        = "${path.root}/../keys/${var.name}-key"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.this.public_key_openssh
  filename        = "${path.root}/../keys/${var.name}-key.pub"
  file_permission = "0644"
}

