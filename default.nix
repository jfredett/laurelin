{ config, lib, pkgs, ...}: {
  options.laurelin = {

  };

  imports = [
    ./infra
    ./services
  ];

  config = {};
}
