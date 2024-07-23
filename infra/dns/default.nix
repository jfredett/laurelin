{ config, lib, pkgs, dns, ...}: 
with lib;
{
  /*

  laurelin.infra = {
    canon = "10.255.1.1"; # maps to archimedes.canon
    domains = {
      "emerald.city" = {
        ip = "172.18.0.5";
        name = "archimedes";
        # enters as `archimedes.emerald.city -> 172.18.0.5
      };
      "pandemon.ium" = {
        ip = "172.19.0.5";
        # enters as `archimedes.pandemon.ium -> 172.19.0.5
        # also creates a virtual NIC on the specified VLAN by lookup.
      };
      "test.domain" = {
        # enters as CNAME archimedes.test.domain. -> archimedes.canon
      };
      "test.domain2" = {
        name = "foo";
        # enters as CNAME foo.test.domain2. -> archimedes.canon
      };
      "test.domain3" = {
        ip = "172.16.0.5";
        vlan = 111;
        # enters as `archimedes.test.domain3 -> 172.16.0.5 and creates the IP with the given VLAN
        # idea (overriding whatever lookup might be done.
      };
    };
  };


  */
  options.laurelin = {
    infra = {
      dns = mkOption {
        type = types.anything;

      };
      canon = mkOption {
        type = types.str;
        description = "The record to be placed in the .canon domain";
      };
      domains = mkOption {
        type = types.attrsOf(submodule {
          ip = {
            type = types.str;
            description = "The IP to assign in the specified domain";
          };
          name = {
            type = types.str;
            description = "The name of the host being placed in the domain";
            default = config.networking.hostName;
          };
          vlan = {
            type = nullOr types.int;
            description = "The VLAN to assign the IP to";
            default = null;
          };
        });
      };
    };
  };

  config = with lib; let
    # just the interface keys
    ifaces = attrNames config.networking.interfaces;
    hostname = config.networking.hostName;
    cfg = config.laurelin.infra;
    domains = {};
  in {
    laurelin = {
      infra = {
        dns = with dns.lib.combinators; {
          subdomains = {
            ${hostname}.A = [(a cfg.canon)];
          };
        };
      };
    };
    # Bond all networks into a single logical network
    # Create VNICs for all relevant domains by lookup or specification
  };
}
