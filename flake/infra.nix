{
  inputs,
  lib,
  self,
  ...
}: let
  inventory = import ../hosts;
  helpers = import ../lib {inherit inputs lib;};
in {
  flake.infra = {
    inherit (inventory) domain;

    servers = lib.mapAttrs (name: host: {
      server_type = host.hcloud.serverType;
      location = host.hcloud.location or "nbg1";
      labels = {purpose = name;} // host.hcloud.labels or {};
      dns.extra = helpers.dnsRecordsFor {
        inherit (inventory) domain;
        inherit name host;
        inherit (self.nixosConfigurations.${name}) config;
      };
    }) (lib.filterAttrs (_: host: host ? hcloud) inventory.hosts);
  };
}
