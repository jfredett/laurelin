{ config, lib, pkgs, modulesPath, ... }: with lib; {
  options.laurelin.netbootable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "Whether to enable building a netbootable image";
  };

  imports = [
    # FIXME: This currently builds an image that automatically logs in on the console, which is not my
    # preference. I assume I need some version of this include, but I need to figure out how to make
    # it not auto-login, at least.

    # BUG: This also hoses builds that don't even netboot, since imports are unconditional.
    # (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];

  config = mkIf config.laurelin.netbootable {
    system.build = {
      netboot = let
        build = config.system.build;
        kernelTarget = pkgs.stdenv.hostPlatform.linux-kernel.target;
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

            echo "Copying ${build.kernel}/${kernelTarget} -> $out/${kernelTarget}"
            ln -s ${build.kernel}/${kernelTarget}         $out/${kernelTarget}
            echo "Copying ${build.netbootRamdisk}/initrd -> $out/initrd"
            ln -s ${build.netbootRamdisk}/initrd          $out/initrd
            echo "Copying ${build.netbootIpxeScript}/netboot.ipxe -> $out/ipxe"
            ln -s ${build.netbootIpxeScript}/netboot.ipxe $out/ipxe

            echo "Writing 'init-command: ${build.toplevel}' to $out/init-command"
            echo "${build.toplevel}" > $out/init-command
          '')
        ];
        preferLocalBuild = true;
      };
    };
  };
}
