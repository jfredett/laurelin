{ config, lib, pkgs, ... }: {
  imports = [
    ./_1password
    ./dns
    ./docker
    ./grafana
    ./netboot
    ./network-storage
    ./prometheus
    ./promtail
    ./reverse-proxy
    ./rustdesk
    ./virtualbox
    ./vm
    ./wayvnc
    ./window-manager
  ];
}
