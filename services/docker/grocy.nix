{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.grocy = {
    enable = mkEnableOption "Enable grocy";
    port = mkOption {
      type = types.int;
      default = 9283;
      description = ''
        The port to expose the grocy service on
      '';
    };
    configRoot = mkOption {
      type = types.str;
      default = config.laurelin.services.docker.host.volumeRoot;
      description = ''
        The root of where to store configuration for this container
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.grocy.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          grocy = { port = cfg.grocy.port; };
        };
      };
    };

    virtualisation.oci-containers.containers = {
      grocy = {
        image = "linuxserver/grocy";
        ports = [ "${toString cfg.grocy.port}:80" ];
        volumes = [
          "${cfg.grocy.configRoot}/grocy:/config"
        ];
        environment = {
          PGID = "100";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.grocy.configRoot}/grocy 0755 root users -"
    ];
  };
}

