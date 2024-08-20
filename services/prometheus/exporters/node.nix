{ config, lib, pkgs, ... }: with lib; {
  # TODO: Rename this to `node`, I suppose I'll have to proxy each of these...
  options.laurelin.services.prometheus.exporters.node = with types; {
    enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Enable the prometheus client
      '';
    };
    port = mkOption {
      type = int;
      default = 9091;
    };
    domain = mkOption {
      type = str;
      default = "emerald.city";
    };
    collectors = mkOption {
      type = listOf str;
      default = [
        "cpu"
        "cpufreq"
        "diskstats"
        "filesystem"
        "interrupts"
        "loadavg"
        "meminfo"
        "netclass"
        "netdev"
        "netstat"
        "stat"
        "systemd"
        "time"
        "uname"
        "vmstat"
      ];
    };
  };

  config = let
    cfg = config.laurelin.services.prometheus.exporters.node;
  in mkIf cfg.enable {

    services = {
      prometheus.exporters = {
        node = {
          enable = true;
          openFirewall = true;
          enabledCollectors = cfg.collectors;
          port = cfg.port;
        };
      };
    };
  };
}

