{ config, lib, pkgs, narya, ... }: with lib; {
  options.laurelin.services.docker.gluetun = {
    enable = mkEnableOption "Enable docker";

    ports = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Portmappings to pass to the container
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.docker;
  in mkIf cfg.gluetun.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.host.volumeRoot}/gluetun 0755 root users -"
    ];

    virtualisation.oci-containers.containers = {
        gluetun = {
          image = "qmcgaw/gluetun";
          ports = cfg.gluetun.ports;
          volumes = [ "${cfg.host.volumeRoot}/gluetun:/gluetun:rw" ];
          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--device=/dev/net/tun"
          ];
          environment = {
            VPN_SERVICE_PROVIDER = "protonvpn";
            VPN_TYPE = "openvpn";
            # FIXME: turnkey, my dude.
            OPENVPN_USER = narya.infra.vpn.protonvpn.openvpn.creds.user;
            OPENVPN_PASSWORD = narya.infra.vpn.protonvpn.openvpn.creds.password;
            SERVER_COUNTRIES = narya.infra.vpn.protonvpn.server-countries;
          };
        };
    };
  };
}
