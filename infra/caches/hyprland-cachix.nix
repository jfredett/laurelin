{ config, lib, ...}: with lib; {
  options.laurelin.infra.caches.hyprland = {
    enable = mkEnableOption "Enable hyprland cachix";
  };

  config = mkIf config.laurelin.infra.caches.hyprland.enable {
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };
}
