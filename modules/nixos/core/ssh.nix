{
  config,
  lib,
  ...
}: let
  cfg = config.personal.ssh;
in {
  options.personal.ssh = {
    enable = lib.mkEnableOption "ssh access configuration" // {default = true;};

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "ssh public keys for root access (defaults to keys/<host>-key.pub)";
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

    networking.firewall.allowedTCPPorts = [22];
  };
}
