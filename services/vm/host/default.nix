{ config, lib, pkgs, ... }: let
  cfg = config.laurelin.services.vm-host;
in {
  options.laurelin.services.vm-host = {
    enable = lib.mkEnableOption "Enable VM Hosting on this machine";

    backup_path = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/libvirtd/backups";
      description = "Path to backup the libvirt config to";
    };

    bridge_name = lib.mkOption {
      type = lib.types.str;
      default = "dmz";
      description = "Name of the bridge to use for VM networking";
    };

    loadout = lib.mkOption {
      type = lib.types.anything;
      default = {};
      description = "The content to provide to `connections.\"qemu:///system\"`";
    };
  };

  config = lib.mkIf cfg.enable {
    # `libvirt` Config
    security.polkit.enable = true;
    security.polkit.debug = true;

    environment.systemPackages = with pkgs; [
      libvirt
    ];

    virtualisation.libvirtd = {
        enable = true;
        allowedBridges = [
          "virbr1"
          cfg.bridge_name
        ];
    };

    ## NixVirt setup

    virtualisation.libvirt =  {
      enable = true;
      connections."qemu:///system" = config.laurelin.services.vm-host.loadout;
    };
  };
}
