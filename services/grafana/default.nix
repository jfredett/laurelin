{ config, lib, pkgs, narya, ... }: with lib; {
  options.laurelin.services.grafana = with types; {
    enable = mkEnableOption "Enable grafana";
    port = mkOption {
      type = int;
      default = 3000;
    };
    domain = mkOption {
      type = str;
      default = "emerald.city";
    };

    # TODO: This should be a list of dashboard _providers_, any system can be a provider of it's own
    # dashboards, as well as cross-system dashboards. The dashboard can be controlled by the local
    # role, but ultimately it triggers changes to configuration in this machine, which is a little
    # spooky, but I like the idea of multiple independent dashboard providers, makes it easy to do
    # comparison/improvement while also having the old dash for comparisons testing.
    dashboards = mkOption {
      type = anything;
      default = [];
      description = ''
        list of paths to grafana dashboards
      '';
    };
  };


  # TODO: Provision an admin user

  config = let
    cfg = config.laurelin.services.grafana;
    dashboard_folder = pkgs.linkFarmFromDrvs "grafana-dashboard" cfg.dashboards;
  in mkIf cfg.enable {
    services.grafana = {
        enable = true;
        settings = {
          admin_password = narya.services.grafana.security.admin_password;

          server = {
            domain = "grafana.${cfg.domain}";
            port = 3000;
            addr = "127.0.0.1";
          };
        };

        provision = {
          enable = true;

          dashboards = {
            settings = {
              providers = [
                {
                  name = "system-view";
                  options.path = dashboard_folder;
                }
              ];
            };
          };

          datasources.settings = {
            apiVersion = 1;

            # TODO: These should be contingent not on a matched domain, but on the config itself,
            # if the underlying service is enabled, then these datasources can add themselves in
            # their respective modules. Tell don't ask.
            datasources = [
              {
                name = "loki";
                type = "loki";
                url = "http://loki.${cfg.domain}";
              }
              {
                name = "prometheus";
                type = "prometheus";
                url = "http://prometheus.${cfg.domain}";
              }
            ];

            deleteDatasources = [
              { name = "loki"; orgId = 1; }
              { name = "prometheus"; orgId = 1; }
            ];
          };
        };
      };
  };
}

