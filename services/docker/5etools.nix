{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.services.docker.fivey-tools = {
    enable = mkEnableOption "Enable 5etools";
    confRoot = mkOption {
      type = types.str;
      description = ''
        Where the configuration is stored
      '';
    };

  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.fivey-tools.enable {
      laurelin.services = {
        reverse-proxy = {
          domain = "emerald.city";
          services = {
            "5e" = { port = 20000; };
          };
        };
      };

      systemd = {
        tmpfiles.rules = [
          "d ${cfg.fivey-tools.confRoot} 0755 root users -"
        ];

        services.fivey-tools-updater = {
          description = "5e.tools content updater";
          after = [ "podman-fivey-tools.service" ];
          requires = [ "podman-fivey-tools.service" ];
          path = [ pkgs.git ];
          serviceConfig = {
            Type = "simple";
            RemainAfterExit = "yes";
            ExecStart = with pkgs; pkgs.writeShellScript "5e-tools-updater.sh" /* bash */ ''
              set -x
              rm -rf ${cfg.fivey-tools.confRoot}/core
              git clone "https://github.com/5etools-mirror-3/5etools-src.git" "${cfg.fivey-tools.confRoot}/core"
              git clone "https://github.com/5etools-mirror-3/5etools-img.git" "${cfg.fivey-tools.confRoot}/core/img"
            '';
          };
        };

        timers.fivey-tools-updater = {
          enable = true;
          wantedBy = [ "network.target" ];
          partOf = [ "fivey-tools-updater.service" ];
          description = "Update Minder for 5e.tools";
          timerConfig.OnCalendar = "Sun *-*-* 00:00:00"; # update every week at midnight on sunday
          timerConfig.RandomizedDelaySec = "0s";
        };
      };

      virtualisation.oci-containers.containers = {
        fivey-tools = {
          image = "typhonragewind/5etools:img-1.181.8";
          ports = [ "7775:7775" ];
          volumes = [
            #"${cfg.fivey-tools.confRoot}/homebrew:/data/homebrew"
            "${cfg.fivey-tools.confRoot}/core:/data"
          ];
        };
      };
    };
}
