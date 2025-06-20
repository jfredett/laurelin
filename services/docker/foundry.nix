{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.foundry = {
    enable = mkEnableOption "Enable foundry";
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
      '';
    };
    version = mkOption {
      type = types.str;
      description = ''
        Which version of foundry to run
      '';
    };

  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.foundry.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          foundry = { port = 30000; };
        };
      };
    };

    virtualisation.oci-containers.containers = {
      foundry = {
        image = "felddy/foundryvtt:${cfg.foundry.version}";
        volumes = [
            "${cfg.foundry.confRoot}/data:/data"
        ];
        environmentFiles = [
            "${cfg.foundry.confRoot}/.env"
        ];
        ports = [ "30000:30000" ];
      };
    };
  };
}
