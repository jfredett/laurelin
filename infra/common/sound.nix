{ config, lib, pkgs, ... }: {
  options.laurelin.infra.sound.enable = lib.mkEnableOption "Enable sound support";

  config = lib.mkIf config.laurelin.infra.sound.enable {
    security.rtkit.enable = true;
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
  };
}
