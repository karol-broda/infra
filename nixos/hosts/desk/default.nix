{ sshPubKeys, ... }:

let
  domain = "karolbroda.com";
  deskDomain = "desk.${domain}";
in
{
  imports = [
    ./disk-config.nix
  ];

  system.stateVersion = "25.11";

  networking = {
    hostName = "desk";
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

    firefly = {
      enable = true;
      domain = "firefly.${deskDomain}";
    };

    memos = {
      enable = true;
      domain = "memos.${deskDomain}";
    };

    affine = {
      enable = true;
      domain = "affine.${deskDomain}";
    };
  };

  services.caddy.globalConfig = ''
    email admin@${domain}
  '';
}

