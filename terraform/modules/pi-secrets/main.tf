resource "onepassword_item" "age_key" {
  vault    = var.vault_id
  title    = var.name
  category = "secure_note"

  section {
    label = "Age Key"

    field {
      label = "key_file"
      type  = "CONCEALED"
      value = var.age_key_file
    }
  }
}

resource "local_sensitive_file" "age_key" {
  content         = var.age_key_file
  filename        = "${path.root}/../keys/age/${var.name}.txt"
  file_permission = "0600"
}
