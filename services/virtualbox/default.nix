{ config, pkgs, lib, ... }: {
  options.laurelin.services.virtualbox = {
    enable = lib.mkEnableOption "Enable VirtualBox";
  };

  config = lib.mkIf config.laurelin.services.virtualbox.enable {
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;

    users.extraGroups.vboxusers.members = [ "jfredett" ];
  };
}
