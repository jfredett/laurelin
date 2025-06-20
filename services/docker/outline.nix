{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.outline = {
    enable = mkEnableOption "Enable outline";
    uploadLocation = mkOption {
      type = types.str;
      description = ''
        Where to store uploaded files
      '';
    };
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
      '';
    };

    dbPass = mkOption {
      type = types.str;
      description = "password for the DB";
    };
  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.outline.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          outline = { port = 10000; };
        };
      };
      docker = {
        redis.enable = true;
        postgres.enable = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.host.dataLocation} 0755 root users -"
    ];

    virtualisation.oci-containers.containers = {
      outline = {
        image = "outlinewiki/outline:latest";
        ports = [ "10000:3010" ];
          #restart = "unless-stopped";
        volumes = [
            "${cfg.outline.dataLocation}:/var/lib/outline/storage"
        ];
        environmentFiles = [
            "${cfg.outline.dataLocation}/env"
        ];
      };
    };
  };
}
