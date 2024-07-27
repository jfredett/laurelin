{ config, lib, pkgs, ... }: with lib; {
  config = let
    cfg = config.laurelin.services.window-manager;
    condition = cfg.enable && cfg.manager == "lxqt";
  in mkIf condition {
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.lxqt.enable = true;
  };
}
