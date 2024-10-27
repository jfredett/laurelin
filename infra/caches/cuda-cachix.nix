{ config, lib, ...}: with lib; {
  options.laurelin.infra.caches.cuda = {
    enable = mkEnableOption "Enable cuda cachix";
  };

  config = mkIf config.laurelin.infra.caches.cuda.enable {
    nix.settings = {
      substituters = [
          "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };
}
