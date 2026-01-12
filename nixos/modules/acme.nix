{
  config,
  lib,
  ...
}: let
  cfg = config.personal.acme;
in {
  options.personal.acme = {
    enable = lib.mkEnableOption "acme/letsencrypt certificate management";

    email = lib.mkOption {
      type = lib.types.str;
      description = "email for acme registration";
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = cfg.email;
    };
  };
}
