{ config, lib, pkgs, ... }:

let
  cfg = config.personal.firefly;
in
{
  options.personal.firefly = {
    enable = lib.mkEnableOption "firefly-iii personal finance manager";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "domain for firefly-iii";
    };

    appKeyFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/firefly-iii/appkey.txt";
      description = "path to file containing the app encryption key";
    };
  };

  config = lib.mkIf cfg.enable {
    services.firefly-iii = {
      enable = true;
      virtualHost = cfg.domain;
      enableNginx = false;

      settings = {
        APP_ENV = "production";
        APP_URL = "https://${cfg.domain}";
        APP_KEY_FILE = cfg.appKeyFile;
        TRUSTED_PROXIES = "**";
        LOG_CHANNEL = "syslog";
        DB_CONNECTION = "sqlite";
      };
    };

    # generate app key if it doesn't exist
    systemd.services.firefly-iii-init = {
      description = "Initialize Firefly III app key";
      wantedBy = [ "multi-user.target" ];
      before = [ "firefly-iii-setup.service" "phpfpm-firefly-iii.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ pkgs.coreutils ];
      script = ''
        if [ ! -f "${cfg.appKeyFile}" ]; then
          mkdir -p "$(dirname "${cfg.appKeyFile}")"
          KEY=$(head -c 32 /dev/urandom | base64)
          echo "base64:$KEY" > "${cfg.appKeyFile}"
          chown firefly-iii:firefly-iii "${cfg.appKeyFile}"
          chmod 600 "${cfg.appKeyFile}"
        fi
      '';
    };

    # allow caddy to access the php-fpm socket
    users.users.caddy.extraGroups = [ "firefly-iii" ];

    services.caddy = {
      enable = true;

      virtualHosts."${cfg.domain}" = {
        extraConfig = ''
          root * ${config.services.firefly-iii.package}/public

          php_fastcgi unix/${config.services.phpfpm.pools.firefly-iii.socket}

          file_server

          encode gzip

          @static {
            path *.css *.js *.ico *.gif *.jpg *.jpeg *.png *.svg *.woff *.woff2
          }
          header @static Cache-Control "public, max-age=31536000"
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
