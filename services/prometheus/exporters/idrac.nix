{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.prometheus.exporters.idrac = with types; {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''
        Enable the prometheus client
      '';
    };
    port = mkOption {
      type = int;
      default = 9093;
    };
    domain = mkOption {
      type = str;
      default = "emerald.city";
    };
  };

  config = let
    cfg = config.laurelin.services.prometheus.exporters.idrac;
  in mkIf cfg.enable {

    services = {
      prometheus.exporters = {
        idrac = {
          enable = true;
          openFirewall = true;
          port = cfg.port;
        };
      };
    };
  };
}

