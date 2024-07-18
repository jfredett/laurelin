{ config, lib, pkgs, dns, ... }: {
  imports = [
    ./dns
  ];
}
