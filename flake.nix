{
  description = "personal infrastructure - hetzner servers managed with terraform and nixos";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko }:
    let
      lib = nixpkgs.lib;

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = lib.genAttrs supportedSystems;

      mkPkgs = system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = false;
            allowUnfreePredicate = pkg:
              let name = lib.getName pkg;
              in name == "terraform";
          };
        };

      mkHost = { name, system ? "x86_64-linux", profile ? "server", extraModules ? [] }:
        let
          sshPubKeyPath = ./keys/${name}-key.pub;
          sshPubKeys = if builtins.pathExists sshPubKeyPath
            then [ (lib.strings.trim (builtins.readFile sshPubKeyPath)) ]
            else [];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit sshPubKeys; };
          modules = [
            disko.nixosModules.disko
            ./nixos/modules
            ./nixos/profiles/${profile}.nix
            ./nixos/hosts/${name}
          ] ++ extraModules;
        };

      hosts = {
        matrix = {
          name = "matrix";
          system = "x86_64-linux";
          profile = "server";
        };

        desk = {
          name = "desk";
          system = "x86_64-linux";
          profile = "server";
        };
      };

      mkShell = system:
        let
          pkgs = mkPkgs system;
          scriptsDir = ./scripts;
        in
        pkgs.mkShell {
          packages = with pkgs; [
            terraform
            nixos-anywhere
            rsync
            jq
          ];

          shellHook = ''
            export PATH="${scriptsDir}:$PATH"

            if [ -n "''${ZSH_VERSION:-}" ]; then
              _matrix_hosts() {
                local hosts
                hosts=(${lib.concatStringsSep " " (builtins.attrNames hosts)})
                _describe 'hostname' hosts
              }

              compdef _matrix_hosts deploy rebuild ssh-to
            fi

            if [ -n "''${PS1:-}" ]; then
              echo "terraform: $(terraform -version | head -1)"
              echo ""
              echo "available commands: tf, deploy, rebuild, ssh-to"
            fi
          '';
        };
    in
    {
      devShells = forAllSystems (system: {
        default = mkShell system;
      });

      nixosConfigurations = lib.mapAttrs (_: hostCfg: mkHost hostCfg) hosts;
    };
}
