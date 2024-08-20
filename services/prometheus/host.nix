{ config, lib, pkgs,  ... }: with lib; {
  options.laurelin.services.prometheus.host = with types; {
    enable = mkEnableOption "Enable Prometheus Host";
    port = mkOption {
      type = int;
      default = 9090;
    };
    scrapeConfigs = mkOption {
      # FIXME: this should be a submodule, but who needs strong typing anyway, right?
      type = anything;
      default = [];
    };
  };

  config = let
    cfg = config.laurelin.services.prometheus.host;
  in mkIf cfg.enable {
    services = {
      prometheus = {
        enable = true;
        port = cfg.port;
        scrapeConfigs = cfg.scrapeConfigs;
      };
    };
  };
}
