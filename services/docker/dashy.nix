{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.dashy = {
    enable = mkEnableOption "Enable dashy";
  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.jellyfin.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          dashy = { port = 8080; };
        };
      };
    };

    # This is wrong, I need to parse cfg.volumes for this.
    systemd.tmpfiles.rules = [
      "d ${cfg.host.volumeRoot}/dashy 0755 root users -"
    ];

    virtualisation.oci-containers.containers = {
        dashy = {
          image = "lissy93/dashy";
          ports = [ "8001:8080" ];
          volumes = [
            "${cfg.host.volumeRoot}/dashy:/dashy:rw"
          ];
        };
    };
  };
}
