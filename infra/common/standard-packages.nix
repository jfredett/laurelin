{ config, lib, pkgs, ... }: with lib; {
  options.laurelin.infra.standard-packages.enable = mkEnableOption "Install standard packages";

  config = mkIf config.laurelin.infra.standard-packages.enable {
    environment.systemPackages = with pkgs; [
      neovim
      python3
      wget
      lsof
      nmap
      inetutils
      git
      curl
      jq
      yq
      ripgrep
      dig
    ];
  };
}
