{ config, lib, pkgs, ...}: with lib; {
  options.laurelin.services._1password = with types; {
    enable = mkEnableOption "1password";
    withGUI = mkOption {
      type = bool;
      default = true;
      description = "Enable the 1password GUI";
    };
    username = mkOption {
      type = str;
      default = "jfredett";
      description = "The username to use for 1password";
    };
  };

  config = let 
    cfg = config.laurelin.services._1password;
  in mkIf cfg.enable {
    # TODO: This is only available at the system level, not w/i home manager, even though I'm pretty
    # sure it should be in HM.
    environment.systemPackages = with pkgs; [
      _1password-gui
      _1password
      # BUG: This seems to be broken?
      #git-credential-1password
    ];

    programs._1password.enable = cfg.withGUI;
    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ cfg.username ];
    };
  };
}
