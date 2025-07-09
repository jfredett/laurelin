{ config, lib, pkgs, ... }: {
  imports = [
    ./_1password
    ./dns
    ./docker
    ./grafana
    ./k3s
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
