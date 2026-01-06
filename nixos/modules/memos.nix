{ config, lib, ... }:

let
  cfg = config.personal.memos;
in
{
  options.personal.memos = {
    enable = lib.mkEnableOption "memos note-taking app";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "domain for memos";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5230;
      description = "internal port for memos";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/memos";
      description = "directory for memos data";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";

      containers.memos = {
        image = "ghcr.io/usememos/memos:stable";
        autoStart = true;

        ports = [
          "127.0.0.1:${toString cfg.port}:5230"
        ];

        volumes = [
          "${cfg.dataDir}:/var/opt/memos"
        ];

        environment = {
          MEMOS_MODE = "prod";
          MEMOS_PORT = "5230";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
    ];

    services.caddy = {
      enable = true;

      virtualHosts."${cfg.domain}" = {
        extraConfig = ''
          reverse_proxy localhost:${toString cfg.port}
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}

