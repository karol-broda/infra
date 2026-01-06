{ sshPubKeys, ... }:

let
  domain = "karolbroda.com";
  matrixDomain = "matrix.${domain}";
in
{
  imports = [
    ./disk-config.nix
  ];

  system.stateVersion = "25.11";

  networking = {
    hostName = "matrix";
    firewall.enable = true;
  };

  personal = {
    ssh = {
      enable = true;
      authorizedKeys = sshPubKeys;
    };

    acme = {
      enable = true;
      email = "admin@${domain}";
    };

    matrix = {
      enable = true;
      domain = matrixDomain;
      cinnyThemeCss = ./catppuccin-frappe.css;
    };
  };

  services.caddy.globalConfig = ''
    email admin@${domain}
  '';
}

