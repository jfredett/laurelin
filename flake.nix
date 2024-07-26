{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";  # (optionally)
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nixvirt, dns, nur, ... } @ inputs: {
    lib = (import ./lib) inputs; # TODO: Send `system` down to lib? for now I can hardcode
    nixosModules = {
      default = { ... }: {
        imports = [
          nixvirt.nixosModules.default
          nur.nixosModules.nur
          ./default.nix
        ];

        # NOTE: I have no idea why this is needed, I would've assumed it'd've passed through, very
        # strange.
        _module.args = inputs;
      };
    };
  };
}
