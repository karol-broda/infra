{
  inventory,
  lib,
  ...
}: let
  secrets = {
    # relative to the repository root, for scripts
    infraFile = "secrets/infra.yaml";

    hostFile = name: let
      path = ./. + "/${name}.yaml";
    in
      if builtins.pathExists path
      then path
      else null;

    # admins can read everything, each host only its own file
    sopsConfig.creation_rules =
      [
        {
          path_regex = "${lib.escapeRegex secrets.infraFile}$";
          key_groups = [{age = inventory.admins;}];
        }
      ]
      ++ lib.mapAttrsToList (name: host: {
        path_regex = "secrets/${lib.escapeRegex name}\\.yaml$";
        key_groups = [{age = inventory.admins ++ [host.ageKey];}];
      }) (lib.filterAttrs (_: host: host.ageKey != null) inventory.hosts);
  };
in {
  _module.args.secrets = secrets;

  perSystem = {pkgs, ...}: {
    packages.sops = pkgs.writeShellApplication {
      name = "sops";
      text = ''exec ${lib.getExe pkgs.sops} --config ${pkgs.writeText "sops.yaml" (builtins.toJSON secrets.sopsConfig)} "$@"'';
      meta.description = "sops with creation rules derived from the host inventory";
    };
  };
}
