{
  lib,
  pkgs,
  ...
}: {
  time.timeZone = lib.mkDefault "UTC";

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
    jq
  ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };
  };
}
