{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./server.nix
  ];
}
