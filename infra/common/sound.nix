{ config, lib, pkgs, ... }: {
  options.laurelin.infra.sound.enable = lib.mkEnableOption "Enable sound support";

  config = lib.mkIf config.laurelin.infra.sound.enable {
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
