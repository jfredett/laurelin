{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.prometheus.exporters.domain = with types; {
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
    cfg = config.laurelin.services.prometheus.exporters.domain;
  in mkIf cfg.enable {

    services = {
      prometheus.exporters = {
        domain = {
          enable = true;
          openFirewall = true;
          port = cfg.port;
        };
      };
    };
  };
}

