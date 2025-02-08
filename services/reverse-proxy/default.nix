{ config, lib, narya, pkgs, ...}: with lib; {
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
          ssl = mkOption {
            type = bool;
            default = false;
          };
          proxyWebsockets = mkOption {
            type = bool;
            default = false;
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
            default = 80;
          };
          proxyWebsockets = mkOption {
            type = bool;
            default = false;
          };
          ssl = mkOption {
            type = bool;
            default = false;
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
      users.extraUsers.nginx = {
        extraGroups = [ "keys" ];
      };


      # TODO: Rev Proxy to another machine/cluster?
      services.nginx = {
        enable = true;

        clientMaxBodySize = "500m";
        # TODO: Only turn this on if the exporter is on?
        statusPage = true;

        virtualHosts = let
          mkService = name: conf: {
            "${name}.${cfg.domain}" = {

              forceSSL = conf.ssl;
              sslCertificate = mkIf conf.ssl narya.infra.trusted-certs."${name}.${cfg.domain}";
              sslCertificateKey = "/run/keys/${name}.${cfg.domain}.key";

              locations."/" = let
                # TODO: There should be a frontend/backend proto distinction.
                proto = if conf.ssl then "https" else "http";
              in {
                proxyPass = "http://${conf.address}:${toString conf.port}";
                recommendedProxySettings = true;
                proxyWebsockets = conf.proxyWebsockets;
              };
            };
          };
          serviceDefs = attrValues (mapAttrs mkService cfg.services); # map mkService (attrValues cfg.services);
          fdqnDef = {
            "${config.networking.fqdn}" = {
              serverName = "${config.networking.fqdn}";
              forceSSL = cfg.fqdn.ssl;
              sslCertificate = mkIf cfg.fqdn.ssl narya.infra.trusted-certs."${config.networking.fqdn}";
              sslCertificateKey = "/run/keys/${config.networking.fqdn}.key";
              locations."/" = let
                proto = if cfg.fqdn.ssl then "https" else "http";
              in {
                proxyPass = "${proto}://${cfg.fqdn.address}:${toString cfg.fqdn.port}";
                proxyWebsockets = cfg.fqdn.proxyWebsockets;
                recommendedProxySettings = true;
              };
            };
          };
        in mkMerge (serviceDefs ++ [fdqnDef]);
      };
    };
}
