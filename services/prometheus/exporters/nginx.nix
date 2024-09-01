{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.prometheus.exporters.nginx = with types; {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''
        Enable the prometheus client
      '';
    };
    port = mkOption {
      type = int;
      default = 9096;
    };
    domain = mkOption {
      type = str;
      default = "emerald.city";
    };
  };

  config = let
    cfg = config.laurelin.services.prometheus.exporters.nginx;
  in mkIf cfg.enable {

    services = {
      prometheus.exporters = {
        nginx = {
          enable = true;
          openFirewall = true;
          port = cfg.port;
        };
      };
    };
  };
}

