{ config, lib, pkgs, hyprland, stylix, ... }: with lib; {
  options = {
    laurelin.services.window-manager.hyprland = {
      enable = mkEnableOption "Enable the Hyprland Desktop Environment";
      # TODO: Optimus setup should be injected
    };
  };

  config = let
    cfg = config.laurelin.services.window-manager;
    condition = cfg.enable && cfg.manager == "hyprland";
  in mkIf condition {
    programs = {
      hyprland = {
        enable = true;

        # set the flake package
        package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Borrowed from: https://github.com/sjcobb2022/nixos-config/blob/main/hosts/common/optional/greetd.nix
    services.greetd = let
      tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
      hyprland-session = "${hyprland.packages.${pkgs.system}.hyprland}/share/wayland-sessions";
    in {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time ";
          user = "greeter";
        };
      };
    };

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    services.xserver.videoDrivers = mkIf (cfg.hyprland.gpu == "nvidia") [ "nvidia" ];
    hardware.nvidia = mkIf (cfg.hyprland.gpu == "nvidia") {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
