{ config, lib, pkgs, narya, ... }: with lib; {
  # imports = [
  #   ./control.nix
  #   ./worker.nix
  #   ./registry.nix
  # ];

  options.laurelin.services.k3s = with types; {
    enable = mkEnableOption "Enable k3s";
    role = mkOption {
      default = "server";
      description = ''
        set k3s role
      '';
    };
    nfs = {
      enable = mkEnableOption "Enable NFS";
      host = mkOption {
        description = ''
          set nfs server to attach to the nfs driver
        '';
      };
    };
    vault-operator = {
      enable = mkEnableOption "Enable Vault Operator";
    };
  };

  config = let
    cfg = config.laurelin.services.k3s;
  in mkIf cfg.enable {

      environment.systemPackages = if cfg.nfs.enable then [ pkgs.nfs-utils ] else [];
      boot.supportedFilesystems = if cfg.nfs.enable then [ "nfs" ] else [];

      networking.firewall = {
        allowedTCPPorts = [
          6443 # required so that pods can reach the API server (running on port 6443 by default)
          2379 # etcd clients: required if using a "High Availability Embedded etcd" configuration
          2380 # etcd peers: required if using a "High Availability Embedded etcd" configuration
        ];

        allowedUDPPorts = [
          8472 # flannel: required if using multi-node for inter-node networking
        ];
      };

      services = {
        rpcbind.enable = lib.mkForce cfg.nfs.enable;
        k3s = {
          enable = true;
          role = "server";
          configPath = narya.infra.k3s.config;
          extraFlags = toString [
            "--debug" # Optionally add additional args to k3s
          ];

          manifests = let
            # FIXME: This currently hardcodes emerald.city as the domain. Prefer to have it be generic
            vault-ingress-route = ./ingress-routes/vault.yaml;
          in {
            vault-ingress-route = mkIf cfg.vault-operator.enable {
              enable = true;
              source = vault-ingress-route;
            };
          };

          autoDeployCharts = let
              cert_manager_repo = "https://charts.jetstack.io";
              vault_operator_package = "https://github.com/hashicorp/vault-secrets-operator/archive/refs/tags/v0.10.0.tar.gz";
              vault_package = "https://github.com/hashicorp/vault-helm/archive/refs/tags/v0.30.0.tar.gz";
              nfs_provisioner_package = "https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/releases/download/nfs-subdir-external-provisioner-4.0.18/nfs-subdir-external-provisioner-4.0.18.tgz";
          in lib.mkIf (cfg.role == "server") {

              vault = mkIf cfg.vault-operator.enable {
                # repo = "https://helm.releases.hashicorp.com";
                # name = "hashicorp/vault";
                # version = "0.28.1";
                package = pkgs.fetchurl {
                  url = vault_package;
                  hash = "sha256-Ea1F3b+CA8UqAS/Xdo4lD910NGOZbtc9r6vFd/VYIxE=";
                };
                createNamespace = true;
                targetNamespace = "kube-infra";
                values = {
                  ui = {
                    enabled = true;
                  };
                  csi = {
                    enabled = true;
                  };
                  ha = {
                    enabled = true;
                    replicas = 5;
                  };

                };
              };

              nfs-storage = mkIf cfg.nfs.enable {
                  package = pkgs.fetchurl {
                    url = nfs_provisioner_package;
                    hash = "sha256-qEIWPB9e7cSJPh9oXkJJsN3WJTPDyUEijuaglqwwj28=";
                  };
                  targetNamespace = "kube-infra";
                  createNamespace = true;
                  values = {
                    "nfs" = {
                      "server" = cfg.nfs.host;
                      "path" = "/volume1/k8s";
                    };
                    "storageClass" = {
                      "name" = "nancy-nfs";
                    };
                  };
                };
            };
        };
      };

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
