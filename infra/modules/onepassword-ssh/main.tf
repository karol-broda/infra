resource "onepassword_item" "ssh_key" {
  vault    = var.vault_id
  title    = var.name
  category = "secure_note"

  section {
    label = "SSH Key"

    field {
      label = "private_key"
      type  = "CONCEALED"
      value = var.private_key
    }

    field {
      label = "public_key"
      type  = "STRING"
      value = var.public_key
    }

    field {
      label = "server_ip"
      type  = "STRING"
      value = var.server_ip
    }

    field {
      label = "server_fqdn"
      type  = "STRING"
      value = var.server_fqdn
    }
  }
}

