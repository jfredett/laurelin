{ config, lib, pkgs, narya, ... }: with lib; {
  # imports = [
  #   ./control.nix
  #   ./worker.nix
  #   ./registry.nix
  # ];

  options.laurelin.services.k3s = with types; {
    enable = mkEnableOption "Enable k3s";
    role = mkOption {
      type = "string";
      default = "server";
      description = ''
        set k3s role
      '';
    };
  };

  config = let
    cfg = config.laurelin.services.k3s;
  in mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      6443 # required so that pods can reach the API server (running on port 6443 by default)
      2379 # etcd clients: required if using a "High Availability Embedded etcd" configuration
      2380 # etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    networking.firewall.allowedUDPPorts = [
      8472 # flannel: required if using multi-node for inter-node networking
    ];
    services.k3s.enable = true;
    services.k3s.role = "server";
    services.k3s.configPath = narya.infra.k3s.config;

    services.k3s.extraFlags = toString [
      "--debug" # Optionally add additional args to k3s
    ];

    environment.etc."rancher/k3s/registries.yaml".text = /* yaml */ ''
      mirrors:
        docker-registry.emerald.city:
          endpoint:
            - "https://docker-registry.emerald.city/v2"
      configs:
        "docker-registry.emerald.city":
          tls:
            insecure_skip_verify: true
      '';
  };
}
