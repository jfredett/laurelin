{ config, lib, pkgs, ...}: with lib; {
  options.laurelin.services.reverse-proxy = with types; {
    enable = mkEnableOption "Enable reverse proxy";

    domain = mkOption {
      type = str;
      default = "emerald.city";
      description = ''
      The domain to use for the reverse proxy.
      '';
    };

    services = mkOption {
      type = attrsOf (submodule {
        options = {
          address = mkOption {
            type = str;
            default = "localhost";
          };
          port = mkOption {
            type = int;
          };
        };
      });
      default = { };
      description = ''
        A map of service names to addresses and ports. Used to map services to addresses and ports.
      '';
    };

    # TODO: Make this unique
    fqdn = mkOption {
      type = submodule {
        options = {
          address = mkOption {
            type = str;
            default = "localhost";
          };
          port = mkOption {
            type = int;
          };
        };

      };
      default = { };
      description = ''
        where to send the fqdn
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.reverse-proxy;
  in mkIf cfg.enable {
    # TODO: Rev Proxy to another machine/cluster?
    services.nginx = {
      enable = true;

      clientMaxBodySize = "25m";

      virtualHosts = let
        mkService = name: conf: {
          "${name}.${cfg.domain}" = {
            locations."/" = {
              proxyPass = "http://${conf.address}:${toString conf.port}";
              recommendedProxySettings = true;
            };
          };
        };
        serviceDefs = attrValues (mapAttrs mkService cfg.services); # map mkService (attrValues cfg.services);
        fdqnDef = {
          "${config.networking.fqdn}" = {
            serverName = "${config.networking.fqdn}";
            locations."/" = {
              proxyPass = "http://${cfg.fqdn.address}:${toString cfg.fqdn.port}";
              recommendedProxySettings = true;
            };
          };
        };
      in mkMerge (serviceDefs ++ [fdqnDef]);
    };
  };
}