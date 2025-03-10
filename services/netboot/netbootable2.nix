{ config, lib, pkgs, modulesPath, narya, ... }: with lib; {
  options = {
    laurelin.netboot = {
      netbootable = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable building a netbootable image";
      };

      mac = lib.mkOption {
        type = types.str;
        default = "02:ec:de:ad:b0:07";
        description = "The MAC address of the machine to netboot";
      };
    };
  };

  # TODO: Make this import-able as a separate module that clients that want to netboot will have to
  # include. It's impossible to make these imports conditional because it allows for circular
  # reference. I think it's possible to do some hackery, but the simplest solution only leaks a tiny
  # bit of abstraction. I suppose I could change things to a 'include-implies-enable' model, but I
  # also think I can leave that decision to a future version of me.
  imports = [
    (modulesPath + "/installer/netboot/netboot.nix")
    (modulesPath + "/installer/scan/detected.nix")
    (modulesPath + "/installer/scan/not-detected.nix")

    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/profiles/base.nix")
  ];

  config = let
    hostName = config.networking.hostName;
    hostkeys = narya.infra.host-keys;
    hostkey = hostkeys.${hostName} or hostkeys.generic;
  in mkIf config.laurelin.netboot.netbootable {

    services.openssh = {
      # Turn off all prior-defined hostkeys
      hostKeys = mkForce [];
      # Set hostkey to our statically definied key
      extraConfig = ''
        HostKey /etc/ssh/hostkey
      '';
    };

    environment.etc = {
      "ssh/hostkey" = {
        source = hostkey;
        mode = "0400";
      };
    };


    system.build = {
      netboot = let
        build = config.system.build;
      in pkgs.symlinkJoin {
        name = "netboot";
        paths = with config.system.build; [
          netbootRamdisk
          kernel
          (pkgs.runCommand "build-artifacts" { } ''
          echo "Copying Netboot Artifacts to $out"
          mkdir -p $out

          echo "Copying kernel params from ${config.system.build.toplevel}/kernel-params -> $out/kernel-params"
          ln -s "${config.system.build.toplevel}/kernel-params" $out/kernel-params

          echo "Copying init from ${config.system.build.toplevel}/init -> $out/init"
          ln -s "${config.system.build.toplevel}/init" $out/init

          echo "Copying ${build.netbootRamdisk}/initrd -> $out/initrd"
          ln -s ${build.netbootRamdisk}/initrd          $out/initrd

          echo "Writing 'init-command: ${build.toplevel}' to $out/init-command"
          echo "${build.toplevel}" > $out/init-command
          '')
        ];
        preferLocalBuild = true;
      };
    };
  };
}
