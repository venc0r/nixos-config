{
  lib,
  config,
  pkgs,
  ...
}:

let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  home.username = "jma";
  home.homeDirectory = "/home/jma";
  home.stateVersion = "25.11";

  # Install packages required by your i3 config and workflow
  home.packages = with pkgs; [
    meslo-lgs-nf

    # i3 related tools
    i3lock
    i3status
    i3blocks
    dmenu
    rofi
    rofi-rbw
    rbw # Bitwarden client
    xdotool # Required by rofi-rbw for typing
    pinentry-gnome3 # Required by rbw for password input (graphical)
    gcr # GNOME Crypto library (needed by pinentry-gnome3)
    feh # Wallpaper
    # picom # Configured via services.picom
    xbacklight
    # dunst # Configured via services.dunst
    pavucontrol # Audio control
    pasystray
    networkmanagerapplet
    autorandr # Display management
    arandr # GUI for xrandr
    xautolock # Auto-lock screen after inactivity
    flameshot # Screenshots
    copyq
    polkit_gnome

    # System monitoring
    sysstat
    lm_sensors
    acpi
    iproute2
    duf # Better df - disk usage utility

    # Applications mentioned in config
    # alacritty # Configured via programs.alacritty
    # zen-browser # Requires flake input or overlay
    thunar
    discord
    qalculate-gtk
    signal-desktop
    element-desktop # Matrix GUI client
    nextcloud-client
    input-leap # KVM switch (keyboard/mouse sharing) - replaces unmaintained barrier
    iamb # Matrix CLI client

    # Browsers
    brave # Privacy-focused browser

    # Media applications
    vlc
    mpv
    gimp
    kdePackages.k3b # CD/DVD burning (KDE Plasma 6)
    picard # MusicBrainz tagger
    # supersonic # Music streaming client - TODO: verify package name
    makemkv # DVD/Blu-ray ripper

    # File managers and utilities
    ranger # Terminal file manager
    pcmanfm # GUI file manager

    # Development tools
    bat # Better cat with syntax highlighting
    opentofu # Infrastructure as code (open-source Terraform alternative)
    vault # HashiCorp Vault CLI
    helm # Kubernetes package manager
    kubectl # Kubernetes CLI
    podman # Rootless container runtime
    gh # GitHub CLI
    ansible # Configuration management
    restic # Backup tool

    # Gaming
    steam
    lutris
    winetricks
    protontricks
    heroic # Epic Games launcher
    # Note: Battle.net runs via Lutris

    # Virtualization
    virt-manager
    qemu

    # Productivity
    onlyoffice-desktopeditors # Office suite

    # System utilities
    wireshark
    glances
    rclone
    rsync
    socat

    # Security and encryption
    gnupg
    # gnome-keyring - Not needed: rbw works without it, GPG has its own agent
    # seahorse - Keyring GUI (not needed without gnome-keyring)

    # Image processing
    imagemagick # Required by blurlock script

    # Networking
    wireguard-tools

    # System info
    # neofetch # Unmaintained, replaced by fastfetch (configured via programs.fastfetch)

    # Theming
    libsForQt5.qtstyleplugin-kvantum # Qt theme engine (Kvantum)
    arc-kde-theme # Arc KDE theme (includes ArcDark Kvantum theme)
    arc-theme # Arc GTK theme
    arc-icon-theme # Arc icon theme
    adwaita-icon-theme # Fallback icons

    # Clipboard and utilities
    xclip # For tmux clipboard integration
    jq # JSON processor
    yq-go # YAML processor

    # Custom Scripts
    scripts.volume-brightness
    scripts.blurlock
    scripts.block-volume
    scripts.block-battery
    scripts.block-cpu
    scripts.block-memory
    scripts.block-disk
    scripts.block-temperature
    scripts.block-bandwidth
    scripts.zen-profile-selector
    scripts.tmux-cht
    scripts.tmux-cal
    scripts.tmux-sessionizer
  ];

  home.file = {
    ".p10k.zsh".source = ../dotfiles/.p10k.zsh;
    ".tmux-cht-languages".source = ../dotfiles/.tmux-cht-languages;
  };

  # Kvantum theme configuration
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=ArcDark
  '';

  # Rofi configuration and themes
  xdg.configFile."rofi/config.rasi".text = ''
    @theme "~/.local/share/rofi/themes/arc_dark_transparent_colors.rasi"
  '';

  xdg.configFile."rofi/powermenu.rasi".text = ''
    /*******************************************************
     * ROFI configs i3 powermenu for EndeavourOS
     * Maintainer: joekamprad [joekamprad //a_t// endeavouros.com]
     *******************************************************/
    configuration {
        font:            "Noto Sans Regular 10";
        show-icons:      false;
        icon-theme:      "Qogir";
        scroll-method:   0;
        disable-history: false;
        sidebar-mode:    false;
    }

    @import "~/.config/rofi/config.rasi"
    /* Insert theme modifications after this */

    window {
        background-color: @background;
        border:           0;
        padding:          10;
        transparency:     "real";
        width:            120px;
        location:         east;
        /*y-offset:       18;*/
        /*x-offset:       850;*/
    }
    listview {
        lines:     7;
        columns:   1;
        scrollbar: false;
    }
    element {
        border:  0;
        padding: 1px;
    }
    element-text {
        background-color: inherit;
        text-color:       inherit;
    }
    element.normal.normal {
        background-color: @normal-background;
        text-color:       @normal-foreground;
    }
    element.normal.urgent {
        background-color: @urgent-background;
        text-color:       @urgent-foreground;
    }
    element.normal.active {
        background-color: @active-background;
        text-color:       @active-foreground;
    }
    element.selected.normal {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    element.selected.urgent {
        background-color: @selected-urgent-background;
        text-color:       @selected-urgent-foreground;
    }
    element.selected.active {
        background-color: @selected-active-background;
        text-color:       @selected-active-foreground;
    }
    element.alternate.normal {
        background-color: @alternate-normal-background;
        text-color:       @alternate-normal-foreground;
    }
    element.alternate.urgent {
        background-color: @alternate-urgent-background;
        text-color:       @alternate-urgent-foreground;
    }
    element.alternate.active {
        background-color: @alternate-active-background;
        text-color:       @alternate-active-foreground;
    }
    scrollbar {
        width:        4px;
        border:       0;
        handle-color: @normal-foreground;
        handle-width: 8px;
        padding:      0;
    }
    mode-switcher {
        border:       2px 0px 0px;
        border-color: @separatorcolor;
    }
    button {
        spacing:    0;
        text-color: @normal-foreground;
    }
    button.selected {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    inputbar {
        spacing:    0;
        text-color: @normal-foreground;
        padding:    1px;
    }
    case-indicator {
        spacing:    0;
        text-color: @normal-foreground;
    }
    entry {
        spacing:    0;
        text-color: @normal-foreground;
    }
    prompt {
        spacing:    0;
        text-color: @normal-foreground;
    }
    inputbar {
        children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
    }
    textbox-prompt-colon {
        expand:     false;
        str:        ":";
        margin:     0px 0.3em 0em 0em;
        text-color: @normal-foreground;
    }

    /*removes the text input line*/
    mainbox {
      children: [listview];
    }
  '';

  home.file.".local/share/rofi/themes/arc_dark_transparent_colors.rasi".text = ''
    /*******************************************************
     * ROFI Arch Dark Transparent colors for EndeavourOS
     * Maintainer: joekamprad [joekamprad //a_t// endeavouros.com]
     *******************************************************/
    * {
        selected-normal-foreground:  rgba ( 255, 147, 5, 100 % );
        foreground:                  rgba ( 196, 203, 212, 100 % );
        normal-foreground:           @foreground;
        alternate-normal-background: rgba ( 45, 48, 59, 1 % );
        red:                         rgba ( 220, 50, 47, 100 % );
        selected-urgent-foreground:  rgba ( 249, 249, 249, 100 % );
        blue:                        rgba ( 38, 139, 210, 100 % );
        urgent-foreground:           rgba ( 204, 102, 102, 100 % );
        alternate-urgent-background: rgba ( 75, 81, 96, 90 % );
        active-foreground:           rgba ( 101, 172, 255, 100 % );
        lightbg:                     rgba ( 238, 232, 213, 100 % );
        selected-active-foreground:  rgba ( 249, 249, 249, 100 % );
        alternate-active-background: rgba ( 45, 48, 59, 88 % );
        background:                  rgba ( 45, 48, 59, 88 % );
        alternate-normal-foreground: @foreground;
        normal-background:           rgba ( 45, 48, 59, 1 % );
        lightfg:                     rgba ( 88, 104, 117, 100 % );
        selected-normal-background:  rgba ( 24, 26, 32, 100 % );
        border-color:                rgba ( 124, 131, 137, 100 % );
        spacing:                     2;
        separatorcolor:              rgba ( 45, 48, 59, 1 % );
        urgent-background:           rgba ( 45, 48, 59, 15 % );
        selected-urgent-background:  rgba ( 165, 66, 66, 100 % );
        alternate-urgent-foreground: @urgent-foreground;
        background-color:            rgba ( 0, 0, 0, 0 % );
        alternate-active-foreground: @active-foreground;
        active-background:           rgba ( 29, 31, 33, 17 % );
        selected-active-background:  rgba ( 26, 28, 35, 100 % );
    }
    window {
        background-color: @background;
        border:           1;
        padding:          5;
    }
    mainbox {
        border:  0;
        padding: 0;
    }
    message {
        border:       2px 0px 0px ;
        border-color: @separatorcolor;
        padding:      1px ;
    }
    textbox {
        text-color: @foreground;
    }
    listview {
        fixed-height: 0;
        border:       2px 0px 0px ;
        border-color: @separatorcolor;
        spacing:      2px ;
        scrollbar:    true;
        padding:      2px 0px 0px ;
    }
    element {
        border:  0;
        padding: 1px ;
    }
    element-text {
        background-color: inherit;
        text-color:       inherit;
    }
    element.normal.normal {
        background-color: @normal-background;
        text-color:       @normal-foreground;
    }
    element.normal.urgent {
        background-color: @urgent-background;
        text-color:       @urgent-foreground;
    }
    element.normal.active {
        background-color: @active-background;
        text-color:       @active-foreground;
    }
    element.selected.normal {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    element.selected.urgent {
        background-color: @selected-urgent-background;
        text-color:       @selected-urgent-foreground;
    }
    element.selected.active {
        background-color: @selected-active-background;
        text-color:       @selected-active-foreground;
    }
    element.alternate.normal {
        background-color: @alternate-normal-background;
        text-color:       @alternate-normal-foreground;
    }
    element.alternate.urgent {
        background-color: @alternate-urgent-background;
        text-color:       @alternate-urgent-foreground;
    }
    element.alternate.active {
        background-color: @alternate-active-background;
        text-color:       @alternate-active-foreground;
    }
    scrollbar {
        width:        4px ;
        border:       0;
        handle-color: @normal-foreground;
        handle-width: 8px ;
        padding:      0;
    }
    mode-switcher {
        border:       2px 0px 0px ;
        border-color: @separatorcolor;
    }
    button {
        spacing:    0;
        text-color: @normal-foreground;
    }
    button.selected {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    inputbar {
        spacing:    0;
        text-color: @normal-foreground;
        padding:    1px ;
    }
    case-indicator {
        spacing:    0;
        text-color: @normal-foreground;
    }
    entry {
        spacing:    0;
        text-color: @normal-foreground;
    }
    prompt {
        spacing:    0;
        text-color: @normal-foreground;
    }
    inputbar {
        children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
    }
    textbox-prompt-colon {
        expand:     false;
        str:        ":";
        margin:     0px 0.3em 0em 0em ;
        text-color: @normal-foreground;
    }
  '';

  # Configure rbw (Bitwarden CLI) to use graphical pinentry
  home.sessionVariables = {
    PINENTRY_PROGRAM = "${pkgs.pinentry-gnome3}/bin/pinentry-gnome3";
  };

  # Configure rbw pinentry via config file (force overwrite)
  xdg.configFile."rbw/config.json".force = true;
  xdg.configFile."rbw/config.json".text = ''
    {
      "email": "joerg.markert@gmail.com",
      "base_url": "https://vaultwarden.v3nc.org",
      "lock_timeout": 14400,
      "sync_interval": 3600,
      "pinentry": "pinentry-gnome3"
    }
  '';

  xdg.configFile."alacritty/gruvbox-dark.toml".text = ''
    # Colors (Gruvbox dark)
    [colors.cursor]
    cursor = '#FF9800'

    # Default colors
    [colors.primary]
    background = '#282828'
    foreground = "#839496"

    # Normal colors
    [colors.normal]
    black   = '#282828'
    red     = '#cc241d'
    green   = '#98971a'
    yellow  = '#d79921'
    blue    = '#458588'
    magenta = '#b16286'
    cyan    = '#689d6a'
    white   = '#a89984'

    # Bright colors
    [colors.bright]
    black   = '#928374'
    red     = '#fb4934'
    green   = '#b8bb26'
    yellow  = '#fabd2f'
    blue    = '#83a598'
    magenta = '#d3869b'
    cyan    = '#8ec07c'
    white   = '#ebdbb2'
  '';

  xdg.configFile."alacritty/gruvbox-light.toml".text = ''
    # Colors (Gruvbox light)

    # Default colors
    [colors.primary]
    # hard contrast background = = '#f9f5d7'
    background = '#fbf1c7'
    # soft contrast background = = '#f2e5bc'
    foreground = '#3c3836'

    # Normal colors
    [colors.normal]
    black   = '#fbf1c7'
    red     = '#cc241d'
    green   = '#98971a'
    yellow  = '#d79921'
    blue    = '#458588'
    magenta = '#b16286'
    cyan    = '#689d6a'
    white   = '#7c6f64'

    # Bright colors
    [colors.bright]
    black   = '#928374'
    red     = '#9d0006'
    green   = '#79740e'
    yellow  = '#b57614'
    blue    = '#076678'
    magenta = '#8f3f71'
    cyan    = '#427b58'
    white   = '#3c3836'
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  imports = [
    ../programs/alacritty.nix
    ../programs/git.nix
    ../programs/tmux.nix
    ../programs/zsh.nix
    ../programs/nvim.nix
    ../programs/vim.nix
    ../programs/zen-browser.nix
    ../programs/copyq.nix
    ../programs/iamb.nix
    ../programs/mangohud.nix
    ../programs/fastfetch.nix
    ../services/dunst.nix
    # picom moved to host-specific config (doesn't work well in VMs)
  ];

  xdg.configFile."i3/i3blocks.conf".text = ''
    # i3blocks config
    separator=false
    markup=pango

    [simple-2]
    full_text=: :
    color=#717171
  '';

  # X11 keyboard configuration
  home.keyboard = {
    layout = "us";
    variant = "altgr-intl";
    options = [ "caps:escape" ]; # Map Caps Lock to Escape
  };

  # X11 session and window manager
  xsession = {
    enable = true;

    windowManager.i3 = {
      enable = true;
      config = {
        modifier = "Mod4";

        # Fonts
        fonts = {
          names = [ "Noto Sans" ];
          style = "Regular";
          size = 10.0;
        };

        # Gaps
        gaps = {
          inner = 0;
          outer = 0;
        };

        # Keybindings
        keybindings = lib.mkOptionDefault {
          # Workspace switching (standard)
          "Mod4+1" = "workspace number 1";
          "Mod4+2" = "workspace number 2";
          "Mod4+3" = "workspace number 3";
          "Mod4+4" = "workspace number 4";
          "Mod4+5" = "workspace number 5";
          "Mod4+6" = "workspace number 6";
          "Mod4+7" = "workspace number 7";
          "Mod4+8" = "workspace number 8";
          "Mod4+9" = "workspace number 9";

          # Move to workspace AND switch to it (Follow)
          "Mod4+Shift+1" = "move container to workspace number 1; workspace number 1";
          "Mod4+Shift+2" = "move container to workspace number 2; workspace number 2";
          "Mod4+Shift+3" = "move container to workspace number 3; workspace number 3";
          "Mod4+Shift+4" = "move container to workspace number 4; workspace number 4";
          "Mod4+Shift+5" = "move container to workspace number 5; workspace number 5";
          "Mod4+Shift+6" = "move container to workspace number 6; workspace number 6";
          "Mod4+Shift+7" = "move container to workspace number 7; workspace number 7";
          "Mod4+Shift+8" = "move container to workspace number 8; workspace number 8";
          "Mod4+Shift+9" = "move container to workspace number 9; workspace number 9";

          # Terminal
          "Mod4+Return" = "exec ${pkgs.alacritty}/bin/alacritty";

          # Browser (with profile selector)
          "Mod4+Tab" = "exec ${scripts.zen-profile-selector}/bin/zen-profile-selector";

          # Kill window
          "Mod4+Shift+q" = "kill";

          # Menus
          "Mod4+space" = "exec --no-startup-id ${pkgs.i3}/bin/i3-dmenu-desktop";

          # Resize mode
          "Mod4+r" = "mode \"resize\"";

          # RBW / Rofi
          "Mod4+p" = "exec ${pkgs.rofi-rbw}/bin/rofi-rbw --action type --target password";
          "Mod4+u" = "exec ${pkgs.rofi-rbw}/bin/rofi-rbw --action type --target username";

          # Audio / PulseAudio
          "Mod4+Ctrl+m" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

          # Navigation (Vim style)
          "Mod4+h" = "focus left";
          "Mod4+j" = "focus down";
          "Mod4+k" = "focus up";
          "Mod4+l" = "focus right";

          # Move windows
          "Mod4+Shift+h" = "move left";
          "Mod4+Shift+j" = "move down";
          "Mod4+Shift+k" = "move up";
          "Mod4+Shift+l" = "move right";

          # Workspaces
          "Mod4+b" = "workspace back_and_forth";
          "Mod4+Shift+b" = "move container to workspace back_and_forth; workspace back_and_forth";

          # Splits
          "Mod4+minus" = "split toggle";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+w" = "layout tabbed";
          "Mod4+Shift+space" = "floating toggle";
          "Mod4+Shift+f" = "floating toggle";
          "Mod4+Shift+s" = "sticky toggle";

          # Scratchpad
          "Mod4+Shift+comma" = "move scratchpad";
          "Mod4+comma" = "scratchpad show";

          # Multimedia Keys (using custom scripts referenced in original config)
          "XF86MonBrightnessUp" = "exec ${pkgs.xbacklight}/bin/xbacklight -inc 1";
          "XF86MonBrightnessDown" = "exec ${pkgs.xbacklight}/bin/xbacklight -dec 1";

          # Volume
          "XF86AudioRaiseVolume" =
            "exec --no-startup-id ${scripts.volume-brightness}/bin/volume-brightness volume_up";
          "XF86AudioLowerVolume" =
            "exec --no-startup-id ${scripts.volume-brightness}/bin/volume-brightness volume_down";
          "XF86AudioMute" =
            "exec --no-startup-id ${scripts.volume-brightness}/bin/volume-brightness volume_mute";

          # Lock
          "Mod4+Escape" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock";
        };

        # Resize modes
        modes = {
          "resize" = lib.mkOptionDefault {
            "h" = "resize shrink width 10 px or 10 ppt";
            "j" = "resize grow height 10 px or 10 ppt";
            "k" = "resize shrink height 10 px or 10 ppt";
            "l" = "resize grow width 10 px or 10 ppt";
            "Return" = "mode \"default\"";
            "Escape" = "mode \"default\"";
          };
        };

        # Assigns
        assigns = {
          "2" = [
            { class = "^(?i)firefox$"; }
            { class = "^Brave-browser$"; }
            { class = "^zen$"; }
          ];
          "3" = [ { class = "^Thunar$"; } ];
          "4" = [
            { class = "^org.remmina.Remmina$"; }
          ];
          "5" = [
            { class = "^TelegramDesktop$"; }
            { class = "^Supersonic$"; }
          ];
          "6" = [
            { class = "^discord$"; }
            { class = "^teams-for-linux$"; }
          ];
          "7" = [ { class = "^zoom$"; } ];
        };

        # Floating rules
        window.commands = [
          {
            command = "floating enable";
            criteria = {
              class = "xfreerdp";
            };
          }
          {
            command = "floating enable";
            criteria = {
              class = "qalculate-gtk";
            };
          }
          {
            command = "resize set 800 600";
            criteria = {
              class = "zoom";
            };
          }
          {
            command = "floating enable";
            criteria = {
              class = "Pavucontrol";
            };
          }
          {
            command = "border pixel 1";
            criteria = {
              class = "^.*";
            };
          }
        ];

        # Colors
        colors = {
          focused = {
            border = "#5294e2";
            background = "#08052b";
            text = "#ffffff";
            indicator = "#8b8b8b";
            childBorder = "#8b8b8b";
          };
          focusedInactive = {
            border = "#08052b";
            background = "#08052b";
            text = "#b0b5bd";
            indicator = "#000000";
            childBorder = "#000000";
          };
          unfocused = {
            border = "#08052b";
            background = "#08052b";
            text = "#b0b5bd";
            indicator = "#383c4a";
            childBorder = "#383c4a";
          };
          urgent = {
            border = "#e53935";
            background = "#e53935";
            text = "#ffffff";
            indicator = "#e1b700";
            childBorder = "#e1b700";
          };
        };

        # Bar
        bars = [
          {
            position = "bottom";
            statusCommand = "${pkgs.i3blocks}/bin/i3blocks -c ${config.xdg.configHome}/i3/i3blocks.conf";
            fonts = {
              names = [ "Noto Sans" ];
              size = 10.0;
            };
            trayOutput = "primary";
            colors = {
              separator = "#e345ff";
              background = "#383c4a";
              statusline = "#ffffff";
              focusedWorkspace = {
                border = "#8b8b8b";
                background = "#b0b5bd";
                text = "#383c4a";
              };
              activeWorkspace = {
                border = "#5294e2";
                background = "#8b8b8b";
                text = "#383c4a";
              };
              inactiveWorkspace = {
                border = "#383c4a";
                background = "#383c4a";
                text = "#b0b5bd";
              };
              urgentWorkspace = {
                border = "#e53935";
                background = "#e53935";
                text = "#ffffff";
              };
            };
          }
        ];

        # Startup commands
        startup = [
          {
            command = "${pkgs.autorandr}/bin/autorandr --load desktop";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.feh}/bin/feh --bg-fill .config/i3/skin.png";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.flameshot}/bin/flameshot";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.pasystray}/bin/pasystray";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.copyq}/bin/copyq";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.xautolock}/bin/xautolock -time 10 -locker \"${scripts.blurlock}/bin/blurlock\"";
            notification = false;
          }
          {
            command = "--no-startup-id ${pkgs.rbw}/bin/rbw-agent";
            notification = false;
          }
        ];
      };
    };
  };

  # GTK theme configuration for dark mode
  gtk = {
    enable = true;

    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };

    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt theme configuration for dark mode (Kvantum)
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
