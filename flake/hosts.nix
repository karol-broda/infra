{
  inputs,
  lib,
  ...
}: let
  inventory = import ../hosts;
  helpers = import ../lib {inherit inputs lib;};
in {
  flake = {
    nixosModules.default = ../modules/nixos;

    nixosConfigurations = lib.mapAttrs (helpers.mkHost inventory) inventory.hosts;
  };
}
