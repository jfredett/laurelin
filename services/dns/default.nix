/*

Design is thus:

1. Blocky frontends, but doesn't serve DNS, just does the blocking.
2. Blocky forwards everything to `nsd` running locally, bound only to localhost
3. nsd runs our zones and forwards everything else to the upstream.

*/
{ config, pkgs, lib, dns, ... }: with lib; {
  options.laurelin.services.dns = with types; with dns.lib.types; {
    enable = mkEnableOption "Enable DNS service";

    zones = mkOption {
      type = anything;
      default = {};
      description = ''
        A list of dns.nix zones.
      '';
    };

    upstreams = mkOption {
      type = types.listOf types.str;
      default = [
        "1.1.1.1"
        "1.4.4.1"
      ];
      description = ''
        A map of upstream DNS servers. Defaults to cloudflare
      '';
    };

    interface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The network interface to bind to. If null, binds on all interfaces.
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.dns;
    specifiedInterface = cfg.interface != null;
    mkMapping = acc: n: acc // { "${n}" = "127.0.0.1:5353"; };
    squattedDomains = foldl' mkMapping {} (attrNames cfg.zones);
  in mkIf cfg.enable {

    networking.firewall = {
      allowedTCPPorts = mkIf (!specifiedInterface) [ 53 853 4000 ];
      allowedUDPPorts = mkIf (!specifiedInterface) [ 53 853 4000 ];

      interfaces.${cfg.interface} = mkIf specifiedInterface {
        allowedTCPPorts = [ 53 853 4000 ];
        allowedUDPPorts = [ 53 853 4000 ];
      };
    };

    environment.systemPackages = [
      pkgs.blocky
    ];

    services = {
      blocky = {
        enable = true;

        settings = {
          upstreams = {
            groups.default = [
              "1.1.1.1"
              "1.4.4.1"
            ];
            strategy = "strict";
            timeout = "15s";
          };

          customDNS = {
            customTTL = "60s";
          };

          conditional.mapping = squattedDomains;

          blocking = {
            blockType = "zeroIP";
            denylists.ads = [
              "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
            ];

            clientGroupsBlock.default = [ "ads" ];
          };
        };
      };

      nsd = let
        mkZone = name: domainDef: {
          data = domainDef;
        };
        zoneDefs = mapAttrs mkZone cfg.zones;
      in {
        zones = zoneDefs;

        enable = true;

        # Listen on localhost only, on 5353.
        port = 5353;
        interfaces = [ "127.0.0.1" "::1" ];
      };
    };
  };
}
