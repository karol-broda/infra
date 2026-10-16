{
  inventory,
  lib,
  self,
  ...
}: {
  _module.args.tofu = {
    dir = "infra";
    inventoryFile = "infra/inventory.auto.tfvars.json";
  };

  # rendered into tofu.inventoryFile by `tf`
  flake.infra = {
    inherit (inventory) domain;

    servers =
      lib.mapAttrs (name: host: {
        server_type = host.hcloud.serverType;
        location = host.hcloud.location or "nbg1";
        labels = {purpose = name;} // host.hcloud.labels or {};
        dns.extra = self.nixosConfigurations.${name}.config.personal.dns.records;
      })
      inventory.servers;
  };
}
