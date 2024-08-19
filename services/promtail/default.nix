{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./jobs
  ];

  options.laurelin.services.promtail = with types; {
    enable = mkOption  {
      type = bool;
      # NOTE: This is opt-out, I don't want to have to manually set this, but I plan to do it
      # where-ever, I'd rather have a spooky default and logs, then an explicit-better-than-implicit
      # dogma.
      default = true;
      description = "Enable promtail";
    };

    lokiUrl = mkOption {
      type = str;
      # TODO: This should be .canon, and loki should properly listen for that address (that might
      # mean giving whatever server this is canon status despite being a VM, not really sure how I
      # want to handle that just yet, probably post VLANification.
      default = "http://loki.emerald.city";
      description = ''
        The location of the Loki server to send logs to
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.promtail;
  in mkIf cfg.enable {
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 9080;
          grpc_listen_port = 0;
        };

        positions = {
          filename = "/tmp/positions.yaml";
        };

        clients = [
          { url = "${cfg.lokiUrl}/loki/api/v1/push"; }
        ];
      };
    };
  };
}
