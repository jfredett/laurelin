{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.infra.standard-packages.enable = mkEnableOption "Install standard packages";

  config = mkIf config.laurelin.infra.standard-packages.enable {
    environment.systemPackages = with pkgs; [
      curl
      dig
      file
      git
      inetutils
      jq
      lsof
      neovim
      nmap
      python3
      ripgrep
      wget
      yq
    ];
  };
}
