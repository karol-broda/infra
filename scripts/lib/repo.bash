# shellcheck shell=bash

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || die "run this from inside the infra repository"
[[ -f $ROOT/hosts/inventory.nix && -d $ROOT/$TOFU_DIR ]] || die "$ROOT is not the infra repository"
cd "$ROOT"

load_tofu_env() {
  eval "$(sops decrypt --output-type json "$INFRA_SECRETS" |
    jq -r 'to_entries[] | "export TF_VAR_\(.key)=\(.value | @sh)"')"
}

write_inventory() {
  info "rendering inventory from hosts/inventory.nix"
  nix eval --json .#infra >"$INVENTORY.tmp"
  mv "$INVENTORY.tmp" "$INVENTORY"
}

prepare_tofu() {
  [[ -f $INVENTORY ]] || write_inventory
  load_tofu_env
}

host_ip() {
  local ip
  prepare_tofu
  ip=$(tofu -chdir="$TOFU_DIR" output -json servers | jq -r --arg host "$1" '.[$host].ipv4 // empty')
  [[ -n $ip ]] || die "no ip for '$1' in opentofu state, run 'tf apply' first"
  echo "$ip"
}

host_key() {
  local key="keys/$1-key"
  [[ -f $key ]] || die "ssh key not found at $key"
  echo "$key"
}
