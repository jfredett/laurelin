{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.registry = {
    enable = mkEnableOption "Enable docker registry";
    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    port = mkOption {
      type = types.int;
      default = 15151;
    };

  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.registry.enable {
      laurelin.services = {
        reverse-proxy = {
          domain = "emerald.city";
          services = {
            docker-registry = { port = 15151; };
          };
        };
      };

      services.dockerRegistry = with cfg.registry; {
        inherit listenAddress port;

        enable = true;
        openFirewall = true;
      };
    };
}
