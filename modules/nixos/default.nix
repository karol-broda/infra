{
  imports = [
    ./core/site.nix
    ./core/nix.nix
    ./core/ssh.nix
    ./core/caddy.nix

    ./services/affine.nix
    ./services/attic.nix
    ./services/firefly.nix
    ./services/matrix.nix
    ./services/memos.nix
    ./services/netbird.nix
    ./services/pocketid.nix
    ./services/taskwarrior.nix
  ];
}
