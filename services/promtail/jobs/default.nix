{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./systemd-journal.nix
  ];
}

