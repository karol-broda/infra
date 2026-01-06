# terraform

hetzner servers with cloudflare dns and 1password ssh key storage.

## setup

```bash
cp terraform.tfvars.example terraform.tfvars
# fill in secrets
tf init
tf plan
tf apply
```

## adding a server

add to `local.servers` in `config.tf`:

```hcl
web = {
  server_type = "cx22"
  location    = "fsn1"
  labels      = { purpose = "web" }
}
```

## modules

- `server` - hetzner server + ssh key generation
- `dns` - cloudflare dns records
- `onepassword-ssh` - 1password ssh key storage

