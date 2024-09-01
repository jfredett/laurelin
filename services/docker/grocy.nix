{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.grocy = {
    enable = mkEnableOption "Enable grocy";
    port = mkOption {
      type = types.int;
      default = 8987;
      description = ''
        The port to expose the grocy service on
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.dashy.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          grocy = { port = cfg.dashy.port; };
        };
      };
    };

    virtualisation.oci-containers.containers = {
      grocy = {
        image = "grocy/grocy";
        ports = [ "${cfg.dashy.port}:8080" ];
        volumes = [
          "${cfg.host.volumeRoot}/grocy:/data"
        ];
      };
    };
  };
}

