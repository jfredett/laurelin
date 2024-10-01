{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./dashy.nix
    ./gluetun.nix
    ./grocy.nix
    ./jellyfin.nix
  ];

  options.laurelin.services.docker = {
    host = {
      enable = mkEnableOption "Enable docker";
      domain = mkOption {
        type = types.str;
        default = "emerald.city";
        description = ''
          The domain to use for the reverse proxy.
        '';
      };

      volumeRoot = mkOption {
        type = types.str;
        default = "/mnt/docker";
        description = ''
          The root of where to create all necessary volumes for laurelin-managed containers
        '';
      };
    };
  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.host.enable {
    # TODO: This should be owned by a different docker user, not root.
    systemd.tmpfiles.rules = [
      "d /mnt/tmp 0755 root users -"
      "d ${cfg.host.volumeRoot} 0755 root users -"
    ];

    laurelin = {
      services.reverse-proxy = {
        enable = true;
        domain = cfg.host.domain;
      };

      nfs = {
        "nancy.canon" = [
          {
            name = "docker";
            path = cfg.host.volumeRoot;
            host_path = "volume1";
          }
        ];
      };
    };

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers = {
        backend = "podman";
      };
    };
  };
}
