{ config, lib, pkgs, dns, ... }: {
  imports = [
    ./common
    ./dns
  ];
}
