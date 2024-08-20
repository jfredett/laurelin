{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.prometheus.exporters.systemd = with types; {
    enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Enable the prometheus client
      '';
    };
    port = mkOption {
      type = int;
      default = 9092;
    };
    domain = mkOption {
      type = str;
      default = "emerald.city";
    };
  };

  config = let
    cfg = config.laurelin.services.prometheus.exporters.systemd;
  in mkIf cfg.enable {

    services = {
      prometheus.exporters = {
        systemd = {
          enable = true;
          openFirewall = true;
          port = cfg.port;
        };
      };
    };
  };
}

