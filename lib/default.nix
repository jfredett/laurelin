{ nixvirt, ... }: let
in {
  vm = with nixvirt.lib; {
    inherit pool network volume domain;
    mkLinuxVMfromTemplate = opts: domain.writeXML (domain.templates.linux opts);
    loadFromFile = path: { definition = path; active = true; };
  };
  util.fold = { join, start, vals }: builtins.foldl' (acc: v: join acc v) start vals;
}
