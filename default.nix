{ config, lib, pkgs, nixvirt, ...}: {
  options.laurelin = {

  };

  imports = [
    ./infra
    ./services
  ];

  config = {

  };
}
