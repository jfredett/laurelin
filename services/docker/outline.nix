{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.outline = {
    enable = mkEnableOption "Enable outline";
    dataLocation = mkOption {
      type = types.str;
      description = ''
        Where to store  files
      '';
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
      "d ${cfg.outline.dataLocation} 0755 root users -"
    ];

    virtualisation.oci-containers.containers = {
      outline = {
        image = "outlinewiki/outline:latest";
        ports = [ "10000:3000" ];
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
