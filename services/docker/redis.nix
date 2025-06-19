{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.redis = {
    enable = mkEnableOption "Enable redis";
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
      '';
    };

  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.redis.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          redis = { port = 6379; };
        };
      };
    };

    virtualisation.oci-containers.containers = {
      redis = {
        image = "redis:8.0.2";
        ports = [ "6379:6379" ];
      };
    };
  };
}
