{ config, lib, pkgs, ... }: with lib; {
  options = with types; {
    laurelin.services.rustdesk.server = {
      enable = mkEnableOption "Enable the rustdesk server";
    };
  };

  config = let
    cfg = config.laurelin.services.rustdesk.server;
    condition = cfg.enable;
  in mkIf condition {
    services.rustdesk-server = {
      enable = true;
      openFirewall = true;
    };
  };
}
