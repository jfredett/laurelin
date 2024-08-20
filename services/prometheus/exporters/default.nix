{ config, lib, pkgs, ... }: with lib; {
  imports = [
#    ./domain.nix
#    ./idrac.nix
    ./nginx.nix
    ./node.nix
#    ./script.nix
    ./systemd.nix
#    ./zfs.nix
  ];
}
