{ config, lib, pkgs, ... }: with lib; {
  imports = [
    ./sound.nix
    ./standard-packages.nix
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
      package = pkgs.nixVersions.stable;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

    nixpkgs.config = {
      allowUnfree = true;
    };

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
