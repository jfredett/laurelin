{ config, ... }: {
  imports = [
    ./hyprland-cachix.nix
    ./cuda-cachix.nix
  ];

  config = {
    # HACK: These should be set in the hyprland ocnfig module and the eventual CUDA/nvidia setup module, I don't want to
    # do that right now because I'm lazy.
    laurelin.infra.caches.hyprland.enable = true;
    laurelin.infra.caches.cuda.enable = true;

  };
}
