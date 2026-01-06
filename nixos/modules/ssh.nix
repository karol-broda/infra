{ config, lib, ... }:

let
  cfg = config.personal.ssh;
in
{
  options.personal.ssh = {
    enable = lib.mkEnableOption "ssh access configuration";

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "ssh public keys for root access";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.root = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}

