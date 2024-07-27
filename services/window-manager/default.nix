{ config, lib, pkgs, ... }: with lib; {
  options = {
    laurelin.services.window-manager = {
      enable = mkEnableOption "Enable the Desktop Environment";
      manager = mkOption {
        type = types.enum [ "kde" "lxqt" ];
        default = "kde";
        description = "The window manager to use";
      };
    };
  };

  imports = [
    ./kde.nix
    ./lxqt.nix
  ];

  config = let
    cfg = config.laurelin.services.window-manager;
  in mkIf cfg.enable {
    services.xserver = {
      enable = true;

      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
