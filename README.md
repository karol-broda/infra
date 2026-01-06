# infrastructure

personal servers on hetzner cloud, managed with terraform and nixos.

## setup

1. configure terraform variables:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

2. initialize and apply terraform:

```bash
tf init
tf plan
tf apply
```

3. deploy nixos to a server:

```bash
deploy <hostname>
```

## commands

- `tf` - terraform wrapper
- `deploy <host>` - initial nixos-anywhere deployment
- `rebuild <host>` - sync config and rebuild on running server
- `ssh-to <host>` - ssh into a server
- `destroy <host>` - destroy server and all associated resources

## adding a new server

1. add entry to `servers` map in `terraform/terraform.tfvars`
2. run `tf apply` to provision infrastructure
3. create host config in `nixos/hosts/<name>/`
4. add host to `hosts` map in `flake.nix`
5. run `deploy <name>` for initial deployment
