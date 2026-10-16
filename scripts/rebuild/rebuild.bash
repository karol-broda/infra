ip=$(host_ip "$host")
key=$(host_key "$host")
ssh_opts=(-i "$key" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new)

steps 2

run_step "copy configuration to $host ($ip)" \
  rsync -az --delete \
  --include='keys/*.pub' --exclude='keys/*' \
  --exclude="$INFRA_SECRETS" \
  --filter=':- .gitignore' \
  --exclude='.git' --exclude="$TOFU_DIR" --exclude='.direnv' --exclude='result*' \
  -e "ssh ${ssh_opts[*]}" \
  . "root@$ip:/etc/nixos/"

# shellcheck disable=SC2029
run_step "switch $host" \
  ssh "${ssh_opts[@]}" "root@$ip" "cd /etc/nixos && nixos-rebuild switch --flake .#$host"
