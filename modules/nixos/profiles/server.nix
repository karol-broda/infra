{
  inputs,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    ./disko-hetzner.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
    kernelModules = ["kvm-intel"];
  };

  networking.useDHCP = true;

  environment.systemPackages = with pkgs; [
    xh
    ghostty.terminfo
  ];
}
