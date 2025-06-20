{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.fivey-tools = {
    enable = mkEnableOption "Enable 5etools";
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
      '';
    };

  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.fivey-tools.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          "5e" = { port = 20000; };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.host.confRoot}/homebrew 0755 root users -"
    ];

    virtualisation.oci-containers.containers = {
      fivey-tools = {
        image = "typhonragewind/5etools:img";
        ports = [ "7775:7775" ];
        volumes = [ "${cfg.fivey-tools.confRoot}/homebrew:/data/homebrew" ];
      };
    };
  };
}
