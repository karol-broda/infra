{
  pkgs,
  arg,
  ...
}: {
  description = "install nixos on a fresh server with nixos-anywhere";
  args = [arg.host];
  runtimeInputs = [pkgs.nixos-anywhere];
  text = ''
    ip=$(host_ip "$host")
    key=$(host_key "$host")

    warn "this wipes the disk of $host ($ip) and installs nixos from scratch"
    confirm "continue?" || die "aborted"

    run_step "install nixos on $host" \
      nixos-anywhere --flake ".#$host" -i "$key" "root@$ip"
  '';
}
