{ config, pkgs, lib, ... }: with lib; {
  options.laurelin.services.dns = {
    enable = mkEnableOption "Enable DNS service";

    dns = mkOption {
      type = types.any;
      description = ''
        The blocky config for the `customDNS` section
      '';
    };

    domains = mkOption {
      type = types.any;
      default = {};
      description = ''
        A map of domain names to conditionally map internally. This is exactly the content of
        `conditional.mapping` in the blocky configuration.
      '';
    };

    upstreams = mkOption {
      type = types.listOf types.string;
      default = [
        "1.1.1.1"
        "1.4.4.1"
      ];
      description = ''
        A map of upstream DNS servers. Defaults to cloudflare
      '';
    };

    interface = mkOption {
      type = nullOr types.string;
      default = null;
      description = ''
        The network interface to bind to. If null, binds on all interfaces.
      '';
    };
  };

  config = let
    cfg = options.laurelin.services.dns;
    specifiedInterface = cfg.interface != null;
  in mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = mkIf !specifiedInterface [ 53 853 4000 ];
    networking.firewall.allowedUDPPorts = mkIf !specifiedInterface [ 53 853 4000 ];

    networking.firewall.${cfg.interface}.allowedTCPPorts = mkIf specifiedInterface [ 53 853 4000 ];
    networking.firewall.${cfg.interface}.allowedUDPPorts = mkIf specifiedInterface [ 53 853 4000 ];
    

    environment.systemPackages = [
      pkgs.blocky
    ];

    services.blocky = {
      enable = true;

      settings = {
        upstreams.groups.default = cfg.upstreams;
        upstreams.timeout = "15s";
        customDNS = cfg.dns;
      };

      conditional.mapping = cfg.domains;

      blocking = {
        blockType = "zeroIP";
        denylists.ads = [
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
        ];

        clientGroupsBlock.default = [ "ads" ];
      };
    };
  };
}

/*
# FIXME: This was all in the parent machine's config, but it should be contained in here.


  # TODO: Move this somehow into the dns module.
  laurelin.blocky.settings = {
    ports = let mkBlockyIPs = port: map (ip: "${ip}:${toString port}") [ "10.255.0.3" ]; in {
      dns = mkBlockyIPs 53;
      tls = mkBlockyIPs 853;
      http = mkBlockyIPs 4000;
      https = mkBlockyIPs 443;
    };
  };

  # TODO: Move blocky ports into the service definition, then pull it from there
  networking.nftables.enable = true;
  networking.firewall = let blockyPorts = [ 53 443 853 4000 ]; in {
    # FIXME: this is probably wrong.
    enable = false;
    allowedTCPPorts = blockyPorts;
    extraInputRules = ''
     # FIXME: I hate this, I wish it were more nix and less string.

     ip saddr 192.168.1.0/24 accept comment "Allow all traffic from KANSAS (192.168.1.0/24)"
     ip saddr 10.255.0.0/16  accept comment "Allow all traffic from CONDORCET (10.255.0.0/16)"
    '';
  };
*/
