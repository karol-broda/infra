{
  pkgs,
  lib,
  ...
}: {
  # disable overlays if nixos-hardware causes issues:
  # hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = lib.mkForce false;

  time.timeZone = lib.mkDefault "UTC";

  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
  boot.tmp.useTmpfs = true;

  hardware.firmware = [pkgs.raspberrypiWirelessFirmware];
  hardware.graphics.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
    jq
    libraspberrypi
    raspberrypi-eeprom
  ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  zramSwap.enable = lib.mkDefault false;

  # placeholder, overridden by sd-image module
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';
}
