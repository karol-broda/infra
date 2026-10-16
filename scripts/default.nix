# every `<name>.nix` and `<name>/default.nix` here is a script: a function of
# the context below returning a spec (see lib/mk-script.nix)
{
  inventory,
  secrets,
  tofu,
  lib,
  ...
}: let
  isScript = file: type:
    if type == "directory"
    then builtins.pathExists ./${file}/default.nix
    else file != "default.nix" && lib.hasSuffix ".nix" file;

  sources = lib.mapAttrs' (file: _: lib.nameValuePair (lib.removeSuffix ".nix" file) ./${file}) (
    lib.filterAttrs isScript (builtins.readDir ./.)
  );
in {
  perSystem = {
    self',
    pkgs,
    ...
  }: let
    context = {
      inherit pkgs lib inventory;

      # reusable argument definitions
      arg.host = {
        name = "host";
        description = "server from hosts/inventory.nix";
        choices = lib.attrNames inventory.servers;
      };
    };

    mkScript = import ./lib/mk-script.nix {
      inherit lib pkgs;
      prelude = builtins.readFile ./lib/stdlib.bash;
      setup = builtins.readFile ./lib/repo.bash;
      env = {
        INFRA_SECRETS = secrets.infraFile;
        TOFU_DIR = tofu.dir;
        INVENTORY = tofu.inventoryFile;
      };
      runtimeInputs = [self'.packages.sops] ++ (with pkgs; [coreutils gnused git jq opentofu]);
    };

    scripts = lib.mapAttrs (name: source: mkScript name (import source context)) sources;
  in {
    packages = scripts;
    checks = scripts;

    apps =
      lib.mapAttrs (_: script: {
        type = "app";
        program = lib.getExe script;
        meta = {inherit (script.meta) description;};
      })
      scripts;
  };
}
