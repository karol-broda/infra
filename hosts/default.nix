{
  inputs,
  lib,
  secrets,
  ...
}: let
  raw = import ./inventory.nix;

  hosts = lib.mapAttrs (_: host:
    {
      system = "x86_64-linux";
      profile = "server";
      ageKey = null;
    }
    // host)
  raw.hosts;

  inventory = {
    inherit (raw) domain admins;
    inherit hosts;
    servers = lib.filterAttrs (_: host: host ? hcloud) hosts;
  };

  sshKeysFor = name: let
    path = ../keys + "/${name}-key.pub";
  in
    lib.optional (builtins.pathExists path) (lib.trim (builtins.readFile path));

  mkHost = name: host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        inputs.sops-nix.nixosModules.sops
        ../modules/nixos
        ../modules/nixos/profiles/${host.profile}.nix
        ./${name}
        {
          nixpkgs.hostPlatform = host.system;
          networking.hostName = lib.mkDefault name;
          personal = {
            inherit (inventory) domain;
            ssh.authorizedKeys = sshKeysFor name;
          };
          sops.defaultSopsFile = lib.mkIf (secrets.hostFile name != null) (secrets.hostFile name);
        }
      ];
    };
in {
  _module.args.inventory = inventory;

  flake = {
    nixosModules.default = ../modules/nixos;
    nixosConfigurations = lib.mapAttrs mkHost hosts;
  };
}
