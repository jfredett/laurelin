{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./sound.nix
    ./standard-packages.nix
    ./hyprland-cachix.nix
    ./remap-capslock.nix
  ];

  config = {
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      optimise = {
        automatic = true;
      };
      package = pkgs.nixFlakes;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };

    time.timeZone = "America/New_York";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      man-pages
      man-pages-posix
      groff
    ];

    documentation = {
      dev.enable = true;

      man = {
        man-db.enable = true;
        mandoc.enable = false;
        generateCaches = true;
      };
    };
  };
}
