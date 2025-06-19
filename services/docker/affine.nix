{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.affine = {
    enable = mkEnableOption "Enable affine";
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
  in mkIf cfg.affine.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          affine = { port = 10000; };
        };
      };
      docker = {
        redis.enable = true;
        postgres.enable = true;
      };
    };

    virtualisation.oci-containers.containers = {
      affine = {
        image = "ghcr.io/toeverything/affine-graphql:stable";
        ports = [ "10000:3010" ];
          #restart = "unless-stopped";
        volumes = [
            "${cfg.affine.uploadLocation}:/root/.affine/storage"
            "${cfg.affine.confRoot}:/root/.affine/config"
        ];
        environmentFiles = [
            "${cfg.affine.confRoot}/.env"
        ];
      };
    };
  };
}
