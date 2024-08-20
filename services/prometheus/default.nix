{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./exporters
    ./host.nix
  ];
}

