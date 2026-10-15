{
  lib,
  self,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        opentofu
        nixos-anywhere
        rsync
        jq
        zstd
        sops
        age
        ssh-to-age
        config.treefmt.build.wrapper
      ];

      shellHook = ''
        export PATH="$(git rev-parse --show-toplevel)/scripts:$PATH"

        if [ -n "''${ZSH_VERSION:-}" ]; then
          _infra_hosts() {
            local hosts
            hosts=(${lib.concatStringsSep " " (lib.attrNames self.nixosConfigurations)})
            _describe 'hostname' hosts
          }

          compdef _infra_hosts deploy rebuild ssh-to destroy
        fi

        if [ -n "''${PS1:-}" ]; then
          echo "$(tofu -version | head -1)"
          echo ""
          echo "available: tf, deploy, rebuild, ssh-to, destroy"
        fi
      '';
    };
  };
}
