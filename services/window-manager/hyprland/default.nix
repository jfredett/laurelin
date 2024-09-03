{ config, lib, pkgs, hyprland, stylix, ... }: with lib; {
  options = {
    laurelin.services.window-manager.hyprland = {
      enable = mkEnableOption "Enable the Hyprland Desktop Environment";
    };
  };

  config = let
    cfg = config.laurelin.services.window-manager;
    condition = cfg.enable && cfg.manager == "hyprland";
  in {
    programs = mkIf condition {
      hyprland = {
        enable = true;

        # set the flake package
        package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };


    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
