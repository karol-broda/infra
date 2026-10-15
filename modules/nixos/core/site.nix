{
  config,
  lib,
  ...
}: {
  options.personal = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "base domain all hosts and services live under (set from hosts/default.nix)";
    };

    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = "admin@${config.personal.domain}";
      defaultText = lib.literalExpression ''"admin@''${config.personal.domain}"'';
      description = "contact address for tls certificates and service admin contacts";
    };
  };
}
