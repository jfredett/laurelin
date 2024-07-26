{ nixvirt, ... }: let
in {
  vm = with nixvirt.lib; {
    mkLinuxVMfromTemplate = opts: domain.writeXML (domain.templates.linux opts);
    loadFromFile = path: { definition = path; active = true; };
  };
}
