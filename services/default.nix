{ config, lib, pkgs, ... }: {
  imports = [
    ./dns
    ./netboot
    ./network-storage
    ./vm
  ];
}
