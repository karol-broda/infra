{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.personal.kiosk;

  browserScript = pkgs.writeShellScript "kiosk-browser" ''
    sleep 2
    exec ${pkgs.chromium}/bin/chromium \
      --kiosk --noerrdialogs --disable-infobars --no-first-run \
      --disable-translate --disable-features=TranslateUI \
      --disable-session-crashed-bubble --disable-component-update \
      --autoplay-policy=no-user-gesture-required \
      --check-for-update-interval=31536000 \
      ${lib.optionalString cfg.disableCursor "--cursor=none"} \
      "${cfg.url}"
  '';
in {
  options.personal.kiosk = {
    enable = lib.mkEnableOption "cage kiosk mode";
    url = lib.mkOption {type = lib.types.str;};
    user = lib.mkOption {
      type = lib.types.str;
      default = "kiosk";
    };
    disableCursor = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    autoLogin = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    rotation = lib.mkOption {
      type = lib.types.enum ["normal" "left" "right" "inverted"];
      default = "normal";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isNormalUser = true;
      home = "/home/${cfg.user}";
      createHome = true;
      extraGroups = ["video" "audio" "input" "render"];
    };

    services.cage = {
      enable = true;
      user = cfg.user;
      program = browserScript;
      extraArguments = lib.optionals (cfg.rotation != "normal") [
        "-r"
        (
          if cfg.rotation == "left"
          then "-90"
          else if cfg.rotation == "right"
          then "90"
          else "180"
        )
      ];
    };

    systemd.services."cage-tty1" = lib.mkIf cfg.autoLogin {
      wantedBy = ["multi-user.target"];
      after = ["systemd-user-sessions.service" "getty@tty1.service"];
      conflicts = ["getty@tty1.service"];
    };

    hardware.graphics.enable = true;
    powerManagement.enable = false;
    environment.systemPackages = [pkgs.chromium];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
