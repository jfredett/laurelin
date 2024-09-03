{ config, lib, pkgs, ... }: with lib; {
  options = {
    laurelin.services.window-manager = {
      enable = mkEnableOption "Enable the Desktop Environment";
      manager = mkOption {
        type = types.enum [ "kde" "lxqt" "hyprland" ];
        default = "kde";
        description = "The window manager to use";
      };
    };
  };

  imports = [
    ./kde.nix
    ./lxqt.nix
    ./hyprland
  ];

  config = let
    cfg = config.laurelin.services.window-manager;
    condition = cfg.enable && cfg.manager != "hyprland";
  in mkIf condition {
    services.xserver = {
      enable = true;

      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
