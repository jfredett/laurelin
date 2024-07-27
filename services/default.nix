{ config, lib, pkgs, ... }: {
  imports = [
    ./_1password
    ./dns
    ./netboot
    ./network-storage
    ./virtualbox
    ./vm
    ./window-manager
  ];
}
