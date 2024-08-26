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
}
