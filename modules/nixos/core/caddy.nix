{
  config,
  lib,
  ...
}: let
  cfg = config.personal.caddy;
  ports = lib.attrValues cfg.reverseProxies;
in {
  options.personal.caddy = {
    reverseProxies = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = {};
      example = {"memos.example.com" = 5230;};
      description = "domains to serve over https, each proxied to a service on localhost:<port>";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.reverseProxies != {}) {
      assertions = [
        {
          assertion = lib.length ports == lib.length (lib.unique ports);
          message = "personal.caddy.reverseProxies: several domains share a backend port: ${lib.generators.toPretty {} cfg.reverseProxies}";
        }
      ];

      services.caddy = {
        enable = true;
        virtualHosts =
          lib.mapAttrs (_: port: {
            extraConfig = ''
              reverse_proxy localhost:${toString port}
            '';
          })
          cfg.reverseProxies;
      };
    })

    (lib.mkIf config.services.caddy.enable {
      services.caddy.globalConfig = ''
        email ${config.personal.adminEmail}
      '';

      networking.firewall.allowedTCPPorts = [80 443];
    })
  ];
}
