{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.grist = {
    enable = mkEnableOption "Enable grist";
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
      '';
    };
    version = mkOption {
      type = types.str;
      default = "latest";
      description = ''
        Which version of grist to run
      '';
    };

  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.grist.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          grist = { port = 8484; };
        };
      };
    };

    virtualisation.oci-containers.containers = {
      grist = {
        image = "gristlabs/grist:${cfg.grist.version}";
        volumes = [
            "${cfg.grist.confRoot}/data:/persist"
        ];
        environmentFiles = [
            "${cfg.grist.confRoot}/.env"
        ];
        ports = [ "8484:8484" ];
      };
    };
  };
}
