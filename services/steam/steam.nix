{ config, lib, pkgs, ... }: with lib; {
  options = with types; {
    laurelin.services.steam = {
      enable = mkEnableOption "Enable Steam";
      controller = {
        xone = { enable = mkEnableOption "enable Xbox One controller support"; };
        xbox = { enable = mkEnableOption "enable Xbox controller support"; };
      };
    };
  };

  config = let
    cfg = config.laurelin.services.steam;
    condition = cfg.enable;
  in mkIf condition {

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    hardware = {
      xone = mkIf cfg.controller.xone.enable { enable = true; };
      xpadneo = mkIf cfg.controller.xbox.enable { enable = true; };
      bluetooth = mkIf (cfg.controller.xbox.enable or cfg.controller.xone.enable) {
        enable = true;
        powerOnBoot = true;
      };
    };

    boot = mkIf cfg.controller.xone.enable {
      extraModprobeConfig = '' options bluetooth disable_ertm=1 '';
    };
  };
}
