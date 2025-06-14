{ config, lib, pkgs, dns, ... }: {
  imports = [
    ./caches
    ./common
    ./dns
  ];
}
