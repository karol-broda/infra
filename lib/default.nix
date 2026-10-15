{
  inputs,
  lib,
}: let
  inherit (inputs) nixpkgs;
in rec {
  sshKeysFor = name: let
    path = ../keys + "/${name}-key.pub";
  in
    lib.optional (builtins.pathExists path) (lib.trim (builtins.readFile path));

  mkHost = inventory: name: host:
    nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        inputs.sops-nix.nixosModules.sops
        ../modules/nixos
        ../modules/nixos/profiles/${host.profile}.nix
        ../hosts/${name}
        {
          nixpkgs.hostPlatform = host.system;
          networking.hostName = lib.mkDefault name;
          personal = {
            inherit (inventory) domain;
            ssh.authorizedKeys = sshKeysFor name;
          };
        }
      ];
    };

  siteHostname = address:
    lib.pipe address [
      (lib.removePrefix "https://")
      (lib.removePrefix "http://")
      (lib.splitString ":")
      builtins.head
    ];

  dnsRecordsFor = {
    domain,
    name,
    host,
    config,
  }: let
    fqdn = "${name}.${domain}";
    vhosts = lib.optionalAttrs config.services.caddy.enable config.services.caddy.virtualHosts;
    hostnames = lib.unique (map siteHostname (lib.concatLists (lib.mapAttrsToList (site: vhost: [site] ++ vhost.serverAliases) vhosts)));
    aliases = lib.filter (h: h != fqdn && lib.hasSuffix ".${domain}" h) hostnames;
  in
    map (h: {
      name = lib.removeSuffix ".${domain}" h;
      type = "CNAME";
      content = fqdn;
    })
    aliases
    ++ host.dns.extra or [];
}
