# infra

opentofu for hetzner servers, cloudflare dns and 1password key storage.
always run it through `tf` (or `nix run .#tf`), never `tofu` directly.

## how inputs get here

- **credentials** (`hcloud_token`, `cloudflare_api_token`, ...) live in
  `secrets/infra.yaml` (sops, your age key only). `tf` exports each key as
  `TF_VAR_<key>`. edit with `sops secrets/infra.yaml`.
- **servers and dns** come from `hosts/inventory.nix`. `tf` renders it
  with `nix eval .#infra` into `inventory.auto.tfvars.json` (gitignored).
  dns records come from each host's `personal.dns.records`; every caddy
  site under the domain becomes a CNAME to its host automatically.

## state

`terraform.tfstate` is encrypted (aes-gcm, pbkdf2) with `state_passphrase`
from `secrets/infra.yaml`. lose that passphrase and the state is gone, so it
is worth keeping a copy in 1password too.

## modules

- `server-stack` - one server: hetzner vm + dns + 1password item
- `server` - hetzner server + ssh key generation
- `dns` - cloudflare dns records
- `onepassword-ssh` - 1password ssh key storage
