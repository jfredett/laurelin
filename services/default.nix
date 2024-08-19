{ config, lib, pkgs, ... }: {
  imports = [
    ./_1password
    ./dns
    ./docker
    ./netboot
    ./network-storage
    ./promtail
    ./reverse-proxy
    ./virtualbox
    ./vm
    ./window-manager
  ];
}
