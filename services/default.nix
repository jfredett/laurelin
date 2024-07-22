{ config, lib, pkgs, dns, ... }: {
  imports = [
    ./dns
    ./netboot
    ./network-storage
  ];
}
