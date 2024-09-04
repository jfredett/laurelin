{ config, lib, pkgs, ... }: with lib; {
  options = with types; {
    laurelin.services.rustdesk.client = {
      enable = mkEnableOption "Enable the rustdesk client";
    };
  };

  config = let
    cfg = config.path.to.module;
    condition = cfg.enable;
  in mkIf condition {
    environment.systemPackages = [
      pkgs.rustdesk
    ];
  };
}
