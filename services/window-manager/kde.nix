{ config, lib, pkgs, ... }: with lib; {
  config = let
    cfg = config.laurelin.services.window-manager;
    condition = cfg.enable && cfg.manager == "kde";
  in mkIf condition {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
  };
}
