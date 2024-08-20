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
          json = true;
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = config.networking.hostName;
          };
        };

        pipeline_stages = [
          # TODO: Do something to make these units more parsable in loki
        ];

        relabel_configs = [
          {
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }
          {
            source_labels = ["__journal__hostname"];
            target_label = "host";
          }
          {
            source_labels = ["__journal__systemd_unit"];
            target_label = "systemd_unit";
            regex = "(.+)";
          }
          {
            source_labels = ["__journal__systemd_user_unit"];
            target_label = "systemd_user_unit";
            regex = "(.+)";
          }
          {
            source_labels = ["__journal__transport"];
            target_label = "transport";
            regex = "(.+)";
          }
          {
            source_labels = ["__journal_priority_keyword"];
            target_label = "severity";
            regex = "(.+)";
          }
        ];
      }
    ];
  };
}

