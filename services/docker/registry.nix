{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.registry = {
    enable = mkEnableOption "Enable docker registry";
    listenAddress = mkOption {
      type = types.str;
      default = "localhost";
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
            docker-registry = { address = "localhost"; port = cfg.registry.port; ssl = true; };
          };
        };
      };

      services.dockerRegistry = with cfg.registry; {
        inherit listenAddress port;

        enable = true;
        openFirewall = true;
      };

      virtualisation.docker = {
        extraOptions = ''
          --insecure-registry ${cfg.registry.listenAddress}:${toString cfg.registry.port}
        '';
      };
    };
}
