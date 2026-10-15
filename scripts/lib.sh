# shellcheck shell=bash
set -euo pipefail

ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
cd "$ROOT"

INVENTORY="infra/inventory.auto.tfvars.json"

die() {
  echo "error: $*" >&2
  exit 1
}

confirm() {
  local reply
  read -r -p "$1 [y/N] " -n 1 reply
  echo
  [[ $reply =~ ^[Yy]$ ]]
}

list_hosts() {
  nix eval --json .#nixosConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]'
}

usage() {
  echo "usage: $1"
  echo
  echo "available hosts:"
  list_hosts | sed 's/^/  /'
  exit 1
}

load_tofu_env() {
  eval "$(sops decrypt --output-type json secrets/infra.yaml |
    jq -r 'to_entries[] | "export TF_VAR_\(.key)=\(.value | @sh)"')"
}

write_inventory() {
  nix eval --json .#infra >"$INVENTORY.tmp"
  mv "$INVENTORY.tmp" "$INVENTORY"
}

run_tofu() {
  [ -f "$INVENTORY" ] || write_inventory
  load_tofu_env
  tofu -chdir=infra "$@"
}

host_ip() {
  local ip
  ip=$(run_tofu output -json servers | jq -r --arg host "$1" '.[$host].ipv4 // empty')
  [ -n "$ip" ] || die "no ip for host '$1' in opentofu state. run 'tf apply' first."
  echo "$ip"
}

host_key() {
  local key="keys/$1-key"
  [ -f "$key" ] || die "ssh key not found at $key"
  echo "$key"
}

ssh_opts_for() {
  SSH_OPTS=(-o StrictHostKeyChecking=accept-new)
  if [ -f "keys/$1-key" ]; then
    SSH_OPTS+=(-i "keys/$1-key" -o IdentitiesOnly=yes)
  fi
}

push_and_switch() {
  local host="$1" target="$2"
  ssh_opts_for "$host"

  echo "copying configuration to $host ($target)..."
  rsync -avz --delete \
    --include='keys/*.pub' --exclude='keys/*' \
    --exclude='secrets/infra.yaml' \
    --filter=':- .gitignore' \
    --exclude='.git' --exclude='infra' --exclude='.direnv' --exclude='result*' \
    -e "ssh ${SSH_OPTS[*]}" \
    . "root@$target:/etc/nixos/"

  echo "rebuilding nixos on $host..."
  # shellcheck disable=SC2029
  ssh "${SSH_OPTS[@]}" "root@$target" "cd /etc/nixos && nixos-rebuild switch --flake .#$host"
}
