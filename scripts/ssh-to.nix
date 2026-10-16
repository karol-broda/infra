{
  pkgs,
  arg,
  ...
}: {
  description = "ssh into a server as root";
  args = [arg.host];
  rest = "ssh args";
  runtimeInputs = [pkgs.openssh];
  text = ''
    ip=$(host_ip "$host")
    key=$(host_key "$host")

    exec ssh -4 -i "$key" -o IdentitiesOnly=yes "root@$ip" "$@"
  '';
}
