# nix-darwin system configuration for MacBook-Pro-von-Jorg.
# Apply with: darwin-rebuild switch --flake .#MacBook-Pro-von-Jorg
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../programs/skhd.nix
  ];

  # Determinate Systems manages the Nix installation — nix-darwin must not conflict.
  nix.enable = false;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    caskArgs.appdir = "/Applications";
    casks = [
      "stats"
      "betterdisplay"
      "podman-desktop"
      "firezone"
      "maccy"
      "owncloud"
      "microsoft-teams"
      "discord"
      "utm"
      "battle-net"
      "claude"
      "citrix-workspace"
    ];
    brews = [
      "displayplacer"
    ];
    masApps = {
      # MikroTik (1323064830) is an iOS "Designed for iPad" app; mas can only install native Mac App Store apps. Install manually via App Store.app once.
      Clockify = 1364502317;
      Bitwarden = 1352778147;
      "Azure VPN Client" = 1553936137;
      LocalSend = 1661733229;
      WireGuard = 1451685025;
      GarageBand = 682658836;
      iMovie = 408981434;
      Keynote = 361285480;
      Numbers = 361304891;
      Pages = 361309726;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.2"
  ];

  services.openssh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';

  environment.etc =
    (import "${inputs.nixos-config-private}/customer-dns.nix") // {
      "resolver/n100.v3nc.org".text = ''
        nameserver 192.168.188.1
      '';
    };

  system.activationScripts.postActivation.text =
    let
      hostsFile = pkgs.writeText "hosts" (''
        ##
        # Host Database
        #
        # localhost is used to configure the loopback interface
        # when the system is booting.  Do not change this entry.
        ##
        127.0.0.1	localhost
        255.255.255.255	broadcasthost
        ::1             localhost
      '' + builtins.readFile "${inputs.nixos-config-private}/hosts");
    in ''
      cp ${hostsFile} /etc/hosts
      chmod 644 /etc/hosts
      chown root:wheel /etc/hosts

      /usr/bin/pmset -c sleep 0 disksleep 0

      if ! /usr/sbin/pkgutil --pkgs 2>/dev/null | /usr/bin/grep -qi citrix; then
        citrix_pkg=$(/usr/bin/find /opt/homebrew/Caskroom/citrix-workspace -maxdepth 2 -name '*.pkg' -print -quit 2>/dev/null)
        if [ -n "$citrix_pkg" ]; then
          /usr/sbin/installer -pkg "$citrix_pkg" -target /
        fi
      fi
    '';

  # User account
  users.users.jmarkert = {
    name = "jmarkert";
    home = "/Users/jmarkert";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINDZk6YhUqDw3WzS8qnfYdTDFg/7vAfdD7oPPQOwfYwv"
    ];
  };

  # home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.jmarkert = import ./home.nix;
  };

  # System-wide shell — disable system compinit, home-manager uses compinit -C
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = false;

  # System packages (minimal — most things live in home-manager)
  environment.systemPackages = with pkgs; [
    curl
    git
    fzf
    neovim
    vim
    wget
  ];

  # macOS system defaults
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      minimize-to-application = true;
      tilesize = 50;
      persistent-apps = [
        "/Users/jmarkert/Applications/Home Manager Apps/Zen Browser (Beta).app"
        "/Users/jmarkert/Applications/Home Manager Apps/Alacritty.app"
        "/Applications/Microsoft Outlook.app"
        "/Applications/1Password.app"
        "/Applications/Microsoft Teams.app"
        "/Applications/Clockify Desktop.app"
        "/Applications/Bitwarden.app"
      ];
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv"; # column view
      NewWindowTarget = "Recents";
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowPathbar = true;
      ShowRemovableMediaOnDesktop = true;
      ShowStatusBar = true;
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 3; # full keyboard access
      ApplePressAndHoldEnabled = false; # key repeat instead of accent menu
      _HIHideMenuBar = false;
      InitialKeyRepeat = 10;
      KeyRepeat = 1;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    trackpad = {
      Clicking = true; # tap to click
    };
    screencapture = {
      type = "png";
      location = "~/Pictures/Screenshots";
    };
    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 2;
      ShowDayOfWeek = false;
      ShowSeconds = false;
    };
    controlcenter = {
      BatteryShowPercentage = false;
      Sound = false;
      Bluetooth = false;
      NowPlaying = false;
    };
    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleMenuBarVisibleInFullscreen = true;
      };
      "~jmarkert/Library/Preferences/ByHost/com.apple.controlcenter" = {
        WiFi = 24;
        Spotlight = 8;
      };
      "~jmarkert/Library/Preferences/ByHost/com.apple.Spotlight" = {
        MenuItemHidden = 1;
      };
      "com.apple.TextInputMenu" = {
        visible = false;
      };
      "com.utmapp.UTM" = {
        FullScreenAutoCapture = true;
        WindowFocusAutoCapture = true;
        ShowMenuIcon = false;
      };
      "org.p0deje.Maccy" = {
        KeyboardShortcut = "shift+command+h";
        popupAtMousePointer = false;
        pasteByDefault = true;
        historySize = 200;
        showInStatusBar = false;
      };
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
    userKeyMapping = [
      {
        # Fn → Left Ctrl
        HIDKeyboardModifierMappingSrc = 1095216660483;
        HIDKeyboardModifierMappingDst = 30064771296;
      }
    ];
  };

  system.primaryUser = "jmarkert";

  # nix-darwin state version
  system.stateVersion = 5;
}
