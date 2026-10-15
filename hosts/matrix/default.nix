{config, ...}: let
  inherit (config.personal) domain;
in {
  system.stateVersion = "25.11";

  networking = {
    interfaces.enp1s0.ipv6.addresses = [
      {
        address = "2a01:4f8:1c1f:ae33::1";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
  };

  personal.matrix = {
    enable = true;
    domain = "matrix.${domain}";
    cinnyThemeCss = ./catppuccin-frappe.css;
    adminEmail = "admin+matrix@${domain}";
  };
}
