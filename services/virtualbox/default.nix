{ config, pkgs, lib, ... }: with lib; {
  options.laurelin.services.virtualbox = {
    enable = mkEnableOption "Enable VirtualBox";
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Users to add to the vboxusers group";
    };

  };

  config = lib.mkIf config.laurelin.services.virtualbox.enable {
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;

    users.extraGroups.vboxusers.members = config.laurelin.services.virtualbox.users;
  };
}
