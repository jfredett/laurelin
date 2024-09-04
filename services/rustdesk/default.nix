{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./client.nix
    ./server.nix
  ];
}
