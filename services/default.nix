{ config, lib, pkgs, ... }: {
  imports = [
    ./_1password
    ./dns
    ./docker
    ./netboot
    ./network-storage
    ./reverse-proxy
    ./virtualbox
    ./vm
    ./window-manager
  ];
}
