{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.jellyfin = {
    enable = mkEnableOption "Enable docker";
    mediaRoot = mkOption {
      type = types.str;
      default = "/mnt/Media";
      description = ''
        The root of where to find media for this container
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.jellyfin.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          jellyfin = { port = 8096; };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.host.volumeRoot}/jellyfin 0755 root users -"
    ];

    virtualisation.oci-containers.containers = {
      jellyfin = {
        image = "jellyfin/jellyfin";
        ports = [ "8096:8096" ];
        volumes = [
          "${cfg.host.volumeRoot}/jellyfin:/config:rw"
          "${cfg.jellyfin.mediaRoot}:/media:rw"
        ];
      };
    };
  };
}
