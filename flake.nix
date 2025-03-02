{
  description = "Laurelin with the golden leaves";

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

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs = { self, nixpkgs, nixvirt, dns, nur, hyprland, ... } @ inputs: let
    pkgs = import nixpkgs { inherit inputs; };
  in {
    # TODO: I think I want to proxy inputs here? So that, e.g., telperion and glamdring can grab the
    # stylix or nix-colors stuff? maybe `laurelin.lib.ext.{flake}`, perhaps extended with any
    # additional functionality I want to add?
    lib = (import ./lib) { inherit nixvirt pkgs; }; # TODO: Send `system` down to lib? for now I can hardcode
    nixosModules = {
      netbootable = { ... }: {
        imports = [
          ./services/netboot/netbootable.nix
        ];
      };

      default = { ... }: {
        imports = [
          nixvirt.nixosModules.default
          nur.modules.nixos.default

          ./default.nix
        ];

        # NOTE: I have no idea why this is needed, I would've assumed it'd've passed through, very
        # strange.
        _module.args = inputs;
      };
    };
  };
}
