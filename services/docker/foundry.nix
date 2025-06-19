{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.foundry = {
    enable = mkEnableOption "Enable foundry";
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
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
          foundry = { port = 50002; };
        };
      };
    };

    # virtualisation.oci-containers.containers = {
    #   foundry = {
    #     image = "foundry:8.0.2";
    #     restart = "always";
    #   };
    # };
  };
}
