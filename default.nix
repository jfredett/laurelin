{ config, lib, pkgs, ...}: {
  options.laurelin = {

  };

  imports = [
    ./infra
  ];

  config = {};
}
