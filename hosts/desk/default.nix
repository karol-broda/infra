{config, ...}: let
  inherit (config.personal) domain;
  deskDomain = "desk.${domain}";
  authDomain = "auth.${domain}";
  secrets = config.sops.secrets;
in {
  system.stateVersion = "25.11";

  sops.secrets = {
    netbird_encryption_key.mode = "0440";
    netbird_coturn_password = {
      owner = "turnserver";
      mode = "0400";
    };
    pocketid_encryption_key.mode = "0440";
    attic_credentials.mode = "0400";
  };

  personal = {
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

    taskwarrior = {
      enable = true;
      domain = "taskwarrior.${deskDomain}";
    };

    pocketid = {
      enable = true;
      domain = authDomain;
      encryptionKeyFile = secrets.pocketid_encryption_key.path;
      appName = domain;
      accentColor = "#ca9ee6";
      sessionDuration = 1440;
      allowSignups = "disabled";
    };

    netbird = {
      enable = true;
      domain = "vpn.${domain}";

      dataStoreEncryptionKeyFile = secrets.netbird_encryption_key.path;

      coturn = {
        enable = true;
        passwordFile = secrets.netbird_coturn_password.path;
      };

      singleAccountModeDomain = domain;

      oidc = {
        configEndpoint = "https://${authDomain}/.well-known/openid-configuration";
        clientId = "fc2afc30-81ed-4d1e-9d0f-a6216798326c";
        audience = "fc2afc30-81ed-4d1e-9d0f-a6216798326c";
      };
    };

    attic = {
      enable = true;
      domain = "cache.${domain}";
      environmentFile = secrets.attic_credentials.path;
      s3 = {
        bucket = "karol-broda";
        endpoint = "https://nbg1.your-objectstorage.com";
        region = "eu-central";
      };
    };
  };

  systemd.services.netbird-management = {
    after = ["podman-pocketid.service"];
    wants = ["podman-pocketid.service"];
  };
}
