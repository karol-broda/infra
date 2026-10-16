{
  description = "personal infrastructure - hetzner servers managed with nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({lib, ...}: {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      imports = [
        inputs.treefmt-nix.flakeModule
        ./hosts
        ./secrets
        ./infra
        ./scripts
      ];

      perSystem = {
        config,
        self',
        pkgs,
        ...
      }: let
        scripts = lib.filterAttrs (_: p: p.passthru.isScript or false) self'.packages;
      in {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            terraform.enable = true;
            shfmt.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          packages =
            lib.attrValues self'.packages
            ++ [
              pkgs.opentofu
              pkgs.age
              pkgs.ssh-to-age
              pkgs.jq
              config.treefmt.build.wrapper
            ];

          shellHook = ''
            if [ -n "''${ZSH_VERSION:-}" ]; then
              ${lib.concatMapStrings (p: p.passthru.zshCompletion) (lib.attrValues scripts)}
            fi

            if [ -n "''${PS1:-}" ]; then
              tofu -version | head -1
              echo
              ${lib.concatStrings (lib.mapAttrsToList (name: p: ''
                printf '  %-10s %s\n' ${lib.escapeShellArgs [name p.meta.description]}
              '')
              scripts)}
            fi
          '';
        };
      };
    });
}
