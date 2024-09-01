{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.prometheus.exporters.ipmi = with types; {
    enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Enable the prometheus client
      '';
    };
    port = mkOption {
      type = int;
      default = 9094;
    };
    domain = mkOption {
      type = str;
      default = "emerald.city";
    };
  };

  config = let
    cfg = config.laurelin.services.prometheus.exporters.ipmi;
  in mkIf cfg.enable {
    services = {
      prometheus.exporters = {
        ipmi = {
          enable = true;
          user = "root";
          openFirewall = true;
          port = cfg.port;
        };
      };
    };
  };
}
