{ config, lib, ... }:

let
  cfg = config.personal.affine;
in
{
  options.personal.affine = {
    enable = lib.mkEnableOption "affine notion-like workspace";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "domain for affine";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3010;
      description = "internal port for affine";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/affine";
      description = "directory for affine data";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";

      containers.affine-redis = {
        image = "redis:7-alpine";
        autoStart = true;

        cmd = [
          "redis-server"
          "--save" "60" "1"
          "--loglevel" "warning"
        ];

        volumes = [
          "${cfg.dataDir}/redis:/data:U"
        ];

        extraOptions = [
          "--network=affine-net"
          "--health-cmd=redis-cli ping || exit 1"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
        ];
      };

      containers.affine-postgres = {
        image = "postgres:16-alpine";
        autoStart = true;

        volumes = [
          "${cfg.dataDir}/postgres:/var/lib/postgresql/data:U"
        ];

        environment = {
          POSTGRES_USER = "affine";
          POSTGRES_PASSWORD = "affine";
          POSTGRES_DB = "affine";
          PGDATA = "/var/lib/postgresql/data/pgdata";
        };

        extraOptions = [
          "--network=affine-net"
          "--health-cmd=pg_isready -U affine -d affine"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
        ];
      };

      containers.affine = {
        image = "ghcr.io/toeverything/affine-graphql:stable";
        autoStart = true;
        dependsOn = [ "affine-redis" "affine-postgres" ];

        ports = [
          "127.0.0.1:${toString cfg.port}:3010"
        ];

        volumes = [
          "${cfg.dataDir}/config:/root/.affine/config:U"
          "${cfg.dataDir}/storage:/root/.affine/storage:U"
          "${cfg.dataDir}/blob:/root/.affine/blob:U"
        ];

        environment = {
          NODE_ENV = "production";
          NODE_OPTIONS = "--import=./scripts/register.js";

          AFFINE_SERVER_HOST = "0.0.0.0";
          AFFINE_SERVER_PORT = "3010";
          AFFINE_SERVER_HTTPS = "true";
          AFFINE_SERVER_EXTERNAL_URL = "https://${cfg.domain}";

          REDIS_SERVER_HOST = "affine-redis";
          REDIS_SERVER_PORT = "6379";
          REDIS_SERVER_DATABASE = "0";

          DATABASE_URL = "postgresql://affine:affine@affine-postgres:5432/affine";

          TELEMETRY_ENABLE = "false";
        };

        extraOptions = [
          "--network=affine-net"
        ];
      };
    };

    systemd.services.podman-affine-network = {
      description = "create podman network for affine";
      wantedBy = [ "multi-user.target" ];
      before = [
        "podman-affine.service"
        "podman-affine-redis.service"
        "podman-affine-postgres.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${config.virtualisation.podman.package}/bin/podman network create affine-net --ignore";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
      "d ${cfg.dataDir}/redis 0750 999 999 -"
      "d ${cfg.dataDir}/postgres 0750 70 70 -"
      "d ${cfg.dataDir}/config 0750 root root -"
      "d ${cfg.dataDir}/storage 0750 root root -"
      "d ${cfg.dataDir}/blob 0750 root root -"
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

