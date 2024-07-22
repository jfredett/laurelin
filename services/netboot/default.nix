{ config, lib, pkgs, ... }: {
  options = {
    laurelin.netboot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the Emerald City Netboot service.";
      };
      image_path = lib.mkOption {
        type = lib.types.path;
        default = "/nix/store/...-nixos-system-.../initrd";
        description = "Path to repository of netboot images, sorted by MAC";
      };
    };
  };

  config = let
    cfg = config.laurelin.netboot;
  in mkIf cfg.enable {
    services.pixiecore = {
      enable = true;
      mode = "api";
      debug = true;
      openFirewall = true;
      apiServer = "http://localhost:10621";
    };

    # I think this is *supposed* to be redundant, but it doesn't seem to set
    # the ports to unfiltered rn
    networking.firewall.allowedTCPPorts = [ 80 443 4011 10621 ];
    networking.firewall.allowedUDPPorts = [ 67 69 4011 ];

    # Systemd service to run a simple sinatra app which just logs the request?
    systemd.services.pixiecore-boot-server = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      script = let 
        rubyEnv = pkgs.ruby.withPackages (ps: with ps; [ 
          pkgs.rubyPackages.sinatra
          pkgs.rubyPackages.puma 
          pkgs.rubyPackages.rack
          pkgs.rubyPackages.rackup
        ]);
        image_path = cfg.image_path;
      in ''
        exec ${rubyEnv}/bin/ruby -e'

        require "sinatra"

        set :port, 10621

        get "/v1" do
          "Emerald City Boot Service"
        end

        get "/v1/boot/:mac" do |_mac|
          image_path = "${image_path}"
          mac = _mac.gsub(":", "")

          puts "boot: #{mac}"
          puts "image_path: #{image_path}"


          # TODO: make these refer back to this server over http where these files then get read out
          # in a stream
          pxe_path = File.join(image_path, mac, "latest")

          init_cmd = File.read(File.join(pxe_path, "init-command")).chomp
          cmdline = "init=#{init_cmd}/init initrd=initrd nohibernate loglevel=4"

          response = {
            "kernel": "file://#{pxe_path}/bzImage",
            "initrd": ["file://#{pxe_path}/initrd"],
            "cmdline": cmdline,
            "message": "Booting #{mac} on #{pxe_path}"
          }.to_json

          puts "Response: #{response}"

          return response
        end
        '
      '';
    };
  };
}
