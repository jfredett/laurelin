{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.dashy = {
    enable = mkEnableOption "Enable dashy";
    conf = mkOption {
      type = types.str;
      description = ''
        Literal YAML configuration for dashy
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.docker;
    dashyCfg = pkgs.writeTextFile {
      name = "conf.yml";
      text = cfg.dashy.conf;
    };
  in mkIf cfg.jellyfin.enable {
    laurelin.services = {
      reverse-proxy = {
        domain = "emerald.city";
        services = {
          dashy = { port = 8081; };
        };
      };
    };

    virtualisation.oci-containers.containers = {
      dashy = {
        image = "lissy93/dashy";
        ports = [ "8081:8080" ];
        volumes = [
          "${dashyCfg}:/app/user-data/conf.yml:ro"
        ];
      };
    };
  };
}
