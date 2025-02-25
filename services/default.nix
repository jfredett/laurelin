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
    ./steam
    ./virtualbox
    ./vm
    ./wayvnc
    ./window-manager
  ];
}
