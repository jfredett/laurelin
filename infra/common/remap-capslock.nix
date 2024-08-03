{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.infra.remap-capslock.enable = mkEnableOption "Enable remapping capslock";

  config = mkIf config.laurelin.infra.remap-capslock.enable {
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = ["*"];
          settings.main = {
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };
}
