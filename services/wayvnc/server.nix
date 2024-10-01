{ config, lib, pkgs, ... }: with lib; {
  options = with types; {
    laurelin.services.wayvnc = {
      server = {
        enable = mkEnableOption "Enable the wayvnc server";
      };
    };
  };

  config = let
    cfg = config.laurelin.services.wayvnc.server;
    condition = cfg.enable;
    wayvncCfg = pkgs.writeText "wayvnc-config" ''
      use_relative_paths=true
      address=10.255.0.0/16
    '';
  in mkIf condition {
    environment.systemPackages = with pkgs; [
      wayvnc
    ];

    # open firewall
    networking.firewall.allowedTCPPorts = [ 5900 5800 ];


    systemd.services.wayvnc = {
      description = "WayVNC Server";
      wantedBy = [ "multi-user.target" ];
      environment = {
        WLR_BACKENDS="headless";
        WAYLAND_DISPLAY="wayland-0";
        XDG_RUNTIME_DIR="/run/user/1000";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.wayvnc}/bin/wayvnc --config ${wayvncCfg}";
        Restart = "always";
        RestartSec = "10";
        User = "nobody";
        Group = "nogroup";
      };
    };
  };
}
