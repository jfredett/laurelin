{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.promtail.jobs.systemd-journal = with types; {
    enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Enable promtail to scrape logs from the systemd journal
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.promtail.jobs.systemd-journal;
  in mkIf cfg.enable {
    services.promtail.configuration.scrape_configs = [
      {
        job_name = "systemd-journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = config.networking.hostName;
          };
        };
        relabel_configs = [
          {
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }
        ];
      }
    ];
  };
}

