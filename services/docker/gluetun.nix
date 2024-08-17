{ config, lib, pkgs, narya, ... }: with lib; {
  options.laurelin.services.docker.gluetun = {
    enable = mkEnableOption "Enable docker";
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
          ports = [
            "8888:8888"
            "8080:8080"
            "8081:8081"
            "6881:6881"
            "6881:6881/udp"
            "6882:6882"
            "6882:6882/udp"
          ];
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
