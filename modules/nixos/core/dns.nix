{
  config,
  lib,
  ...
}: let
  inherit (config.personal) domain;
  fqdn = "${config.networking.hostName}.${domain}";

  siteHostname = address:
    lib.pipe address [
      (lib.removePrefix "https://")
      (lib.removePrefix "http://")
      (lib.splitString ":")
      builtins.head
    ];

  sites = lib.concatLists (
    lib.mapAttrsToList (site: vhost: [site] ++ vhost.serverAliases) config.services.caddy.virtualHosts
  );

  aliases = lib.filter (h: h != fqdn && lib.hasSuffix ".${domain}" h) (lib.unique (map siteHostname sites));
in {
  options.personal.dns.records = lib.mkOption {
    type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
    default = [];
    description = ''
      cloudflare records opentofu creates for this host besides its A/AAAA
      records, with names relative to personal.domain. every caddy site under
      the domain gets a CNAME to the host automatically.
    '';
  };

  config.personal.dns.records = lib.mkIf config.services.caddy.enable (
    map (h: {
      name = lib.removeSuffix ".${domain}" h;
      type = "CNAME";
      content = fqdn;
    })
    aliases
  );
}
