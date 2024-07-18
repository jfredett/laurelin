{ config, pkgs, lib, ... }: with lib; {
  options.laurelin.services.dns = {
    enable = mkEnableOption "Enable DNS service";
    dns = mkOption {
      type = types.any;
      default = {};
      description = ''
      A map of DNS records suitable for use in `blocky`'s `customDNS` configuration.
      '';
    };
    domains = mkOption {
      type = types.any;
      default = {};
      description = ''
      A map of domain names to conditionally map internally.
      '';
    };
    upstreams = mkOption {
      type = types.listOf types.string;
      default = [];
      description = ''
      A map of upstream DNS servers.
      '';
    };
  };

  config = let 
    cfg = options.laurelin.services.dns;
  in mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [ 53 853 4000 ];
    networking.firewall.allowedUDPPorts = [ 53 853 4000 ];

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
