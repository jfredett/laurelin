{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.postgres = {
    enable = mkEnableOption "Enable postgres";
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
      '';
    };

  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.postgres.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          postgres = { port = 5432; };
        };
      };
    };

    virtualisation.oci-containers.containers = {
      postgres = {
        image = "pgvector/pgvector:pg16";
        ports = [ "5432:5432" ];
          #        restart = "always";
        volumes = [
            "${cfg.postgres.confRoot}/data:/var/lib/postgresql/data"
        ];
        environmentFiles = [
            "${cfg.postgres.confRoot}/.env"
        ];
      };
    };
  };
}
