{ pkgs, ... }:

{
  # placeholder for raspberry pi profile
  # will be migrated from my private repo when needed

  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
    jq
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}

