# Network Storage Module
#
# This module allows you to configure NFS and SMB shares on your system.
# It will automatically create the mount points and systemd services to mount the shares.
#
# Example configuration:
#
# services.laurelin = {
#   nfs = {
#     host.emerald.city = {
#       name = "myothershare";
#       host_path = "volume1/myothershare";
#       path = "/mnt/nfs/myothershare";
#       user = "nfs";
#       group = "nfs";
#       perm = "0755";
#     };
#     host.pandemon.ium = {
#       name = "myshare";
#       host_path = "volume1/myshare";
#       path = "/mnt/nfs/myshare";
#       user = "nfs";
#       group = "nfs";
#       perm = "0755";
#     };
#   };
#   smb = {
#     host.pandemon.ium = {
#       name = "myshare";
#       host_path = "myshare";
#       path = "/mnt/smb/myserver/myshare";
#       user = "smb";
#       group = "smb";
#       perm = "0755";
#     };
#   };
# };
#
#
# This will create the following:
# - NFS share mounted at /mnt/nfs/myserver/myshare
# - SMB share mounted at /mnt/smb/myserver/myshare
# - users nfs and smb with uids 8000 and 9000 respectively
# - systemd services to mount the shares
# - systemd services to automatically mount the shares on boot
# - systemd-tmpfiles rules to create the mount points
# - set packages to include all necessary dependencies
#
# You can add as many NFS and SMB shares as you like. The module will automatically
# create the necessary configuration for each share.
#

# TODO: Move `cachefilesd` config into this module, allowing it to be enabled by option.
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.laurelin;

  mkNFSMount = let 
    _mkMount = host: {name, host_path, path, options, ...}: {
      type = "nfs4";
      what = "${host}:/${host_path}/${name}";
      where = path;
      description = "Mount NFS share ${name} from ${host} at ${path}";
      mountConfig = { Options = "nfsvers=4,minorversion=1,${options}"; };
      wantedBy = [ "multi-user.target" ];
    };
  in host: mounts: { mounts = map (_mkMount host) mounts; };

  mkNFSAutomount = let 
    _mkMount = host: { path, ...}: {
        # TODO: Make this an After, but make sure it'll still automatically run.
        wantedBy = [ "multi-user.target" ];
        after = [ "multi-user.target" ];
        where = path;
        description = "Automount NFS share at ${path}";
    };
  in host: mounts: { mounts = map (_mkMount host) mounts; };

  mkSMBMount = let 
    _mkMount = host: {name, host_path, path, options, ...}: {
      type = "smb";
      what = "//${host}/${name}";
      where = "${path}";
      description = "Mount SMB share ${name} from ${host} at ${path}";
      mountConfig = { Options = options; };
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
    };
  in host: mounts: { mounts = map (_mkMount host) mounts; };

  mkSMBAutomount = let 
    _mkMount = host: { path, ...}: {
      # TODO: Make this an After, but make sure it'll still automatically run.
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      where = "${path}";
      description = "Automount SMB share at ${path}";
    };
  in host: mounts: { mounts = map (_mkMount host) mounts; };


  mkOptionSchema = {fsType, defaultOptions, ... }: mkOption {
    type = with types; attrsOf (listOf (submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Name of the ${fsType} share on the host";
        };
        host_path = mkOption {
          type = types.str;
          description = "Path to the ${fsType} share on the host, ex: /volume1/\${name}";
        };
        path = mkOption {
          type = types.str;
          description = "Mount point for the ${fsType} share on the client, ex: /mnt/\${fsType}/\${host}/\${name}. This path will be automatically created via systemd.tmpfiles.rules";
        };
        user = mkOption {
          type = types.str;
          default = strings.toLower fsType;
          description = "User to mount the ${fsType} share as";
        };
        group = mkOption {
          type = types.str;
          default = strings.toLower fsType;
          description = "Group to mount the ${fsType} share as";
        };
        perm = mkOption {
          type = types.str;
          default = "0755";
          description = "Permissions for the ${fsType} share";
        };
        options = mkOption {
          type = types.str;
          default = defaultOptions;
          description = "Additional options to pass to the mount command";
        };
      };
    }));
    default = {};
    description = "${fsType} shares configuration";
  };

in {
  options.laurelin = {
    smb = mkOptionSchema { fsType = "SMB"; defaultOptions = "defaults"; };
    nfs = mkOptionSchema { fsType = "NFS"; defaultOptions = "defaults,soft,bg,retrans=15"; };
  };

  config = let
    hasNFS = (attrNames cfg.nfs) != [];
    hasSMB = (attrNames cfg.smb) != [];
    systemPackages = (if hasNFS then [ pkgs.nfs-utils ] else []) 
                  ++ (if hasSMB then [ pkgs.samba ] else []);
    supportedFilesystems = (if hasNFS then [ "nfs" ] else [])
                        ++ (if hasSMB then [ "smb" ] else []);
    

    nfsMounts = attrValues (mapAttrs mkNFSMount cfg.nfs);
    smbMounts = attrValues (mapAttrs mkSMBMount cfg.smb);
    nfsAutomounts = attrValues (mapAttrs mkNFSAutomount cfg.nfs);
    smbAutomounts = attrValues (mapAttrs mkSMBAutomount cfg.smb);

    mounts = nfsMounts ++ smbMounts;
    automounts = nfsAutomounts ++ smbAutomounts;

    paths = let
      mountConfigs = flatten (attrValues cfg.nfs ++ attrValues cfg.smb);
      mkRule = { path, perm, user, group, ...}: "d ${path} ${perm} ${user} ${group} -";
      rules = map mkRule mountConfigs;
    in { tmpfiles.rules = rules; };

    newConfig = mkMerge (mounts ++ automounts ++ [paths]);

  in {
    environment.systemPackages = systemPackages;
    boot.supportedFilesystems = supportedFilesystems;
    services.rpcbind.enable = true;

    users = {
      groups = {
        nfs = mkIf hasNFS { gid = 8000; };
        smb = mkIf hasSMB { gid = 9000; };
      };
      users = {
        nfs = mkIf hasNFS { uid = 8000; group = "nfs"; isSystemUser = true; shell = "/sbin/nologin"; };
        smb = mkIf hasSMB { uid = 9000; group = "smb"; isSystemUser = true; shell = "/sbin/nologin"; };
      };
    };

    systemd = newConfig;
  };
}

