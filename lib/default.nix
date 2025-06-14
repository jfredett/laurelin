{ nixvirt, pkgs, ... }: let
in {
  vm = with nixvirt.lib; {
    inherit pool network volume domain;
    mkLinuxVMfromTemplate = opts: domain.writeXML (domain.templates.linux opts);
    loadFromFile = path: { definition = path; active = true; };

  };
  util.fold = { join, start, vals }: builtins.foldl' (acc: v: join acc v) start vals;
  mkDashboard = { templateName, dashboardName, args }: with builtins; let
    template = import ../services/grafana/dashboard-templates/${templateName}.nix;
    dashboardJson = toString (toJSON (template args));
  in pkgs.writeText "${dashboardName}.json" dashboardJson;
  # Ideal:

  # Creates a attr set with a `domain-xml` key and a `config` which is the base VM config to build to set up the system
  # from 0
  mkVm = inputs@{ ... }: {
    /* inputs is like:
    hostname = "foo";
    disks = {
      "root" = {
        size = "100G";
        boot_order = 1;
        source = {
          type = "file";
          path = "${inputs.config.networking.hostname}-${name-of-this-node}";
        };
      };
      "/boot/efi" = { ... };
    };
    */
    hwConfig = {
      # cpus = { sockets = 1; dies = 1; clusters = 1; cores = 8; threads = 2 }; # fine-grained
      # cpus = 24; # coarse: automatically creates a 24 core, single-thread machine
      cpus = { count = 24; pinned = true; type = "hyperthread"; }; # logical; tell it the threadcount, some other high level facts, generated config does what you mean
      # memory = "32GB"; # Direct set
      memory = { per_core = "1.5GB"; }; # automatic scaling by corecount
      # other stuff as needed
    };
    modules = [
      inputs.config
      { } # custom module here
    ];

    domain_xml = { hwConfig, nixosConfiguration }: let
      name = inputs.nixosConfiguration.config.networking.hostName;
    in with pkgs; stdenv.mkDerivation (rec {
        inherit name;
        buildInputs = [ libxslt ];
        hwConfigXML = builtins.toXML inputs.hwConfig;
        stylesheet = builtins.toFile "domain-stylesheet.xml" /* xml */ ''
          <?xml version='1.0' encoding='UTF-8'?>
          <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>
            <xsl:template match='/'>
              <Configure>
                <domain type="kvm">
                  <name>${name}</name>
                  <uuid></uuid>
                </domain>
              </Configure>
            </xsl:template>
          </xsl:stylesheet>
        '';

        builder = builtins.toFile "build-${name}" ''
          source $stdenv/setup
          mkdir -p $out
          uuid=$(uuidgen -N ${name} --namespace @oid --sha1)
          echo "${hwConfigXML}" | xsltproc ${stylesheet} - > $out/${name}.xml
        '';
    });
    config = inputs.nixosConfiguration;
  };


}
