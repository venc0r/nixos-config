# Linux home-manager configuration.
# Cross-platform content lives in hosts/home-common.nix.
{
  lib,
  config,
  pkgs,
  ...
}:

let
  scripts = import ./scripts.nix { inherit pkgs; };
  wallpaper = ./nixos_wallpaper.png;
in
{
  home.username = "jma";
  home.homeDirectory = "/home/jma";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    vlc

    # X11 / desktop
    i3lock
    i3status
    i3blocks
    dmenu
    rofi
    rofi-rbw
    xdotool
    feh
    xbacklight
    pavucontrol
    pasystray
    networkmanagerapplet
    autorandr
    arandr
    xautolock
    flameshot
    copyq
    polkit_gnome

    # System monitoring (Linux-specific)
    sysstat
    lm_sensors
    acpi
    iproute2

    # Applications
    qalculate-gtk
    signal-desktop
    element-desktop
    owncloud-client
    input-leap

    # Media
    gimp
    kdePackages.k3b
    picard
    supersonic

    # File management
    pcmanfm
    thunar


    # Virtualisation
    virt-manager
    (lib.hiPrio qemu)



    # Networking
    wireguard-tools

    # Theming
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    arc-kde-theme
    arc-theme
    arc-icon-theme
    adwaita-icon-theme

    # Clipboard / X11
    xclip

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
  ] ++ lib.optionals (!pkgs.stdenv.hostPlatform.isAarch64) [
    pkgs.discord
    pkgs.makemkv
    pkgs.steam
    pkgs.lutris
    pkgs.winetricks
    pkgs.protontricks
    pkgs.heroic
    pkgs.onlyoffice-desktopeditors
    pkgs.wireshark
  ];

  # Linux-specific env vars
  home.sessionVariables = {
    PINENTRY_PROGRAM = "${pkgs.pinentry-gnome3}/bin/pinentry-gnome3";
    QT_QPA_PLATFORMTHEME = "kvantum";
    QT_STYLE_OVERRIDE = "kvantum";
  } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isAarch64 {
    # i3/alacritty scale 2x via Xft.dpi 192.
    # GTK ~1.75x fonts: GDK_DPI_SCALE 0.875 against the 192 dpi (192*0.875=168).
    # (GTK widget chrome stays 1x — X11 GTK has no fractional widget scaling.)
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "0.875";
    # Qt 1.75x crisp (font dpi, not surface scale).
    QT_FONT_DPI = "168";
    # Fyne apps (Supersonic) — own scale mechanism.
    FYNE_SCALE = "1.75";
  };

  xresources.properties = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 {
    "Xft.dpi" = 192;
  };

  # Rofi configuration
  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
        dpi: 192;
    }
    @theme "~/.local/share/rofi/themes/arc_dark_transparent_colors.rasi"
  '';

  xdg.configFile."rofi/powermenu.rasi".text = ''
    configuration {
        font:            "Noto Sans Regular 10";
        show-icons:      false;
        icon-theme:      "Qogir";
        scroll-method:   0;
        disable-history: false;
        sidebar-mode:    false;
    }

    @import "~/.config/rofi/config.rasi"

    window {
        background-color: @background;
        border:           0;
        padding:          10;
        transparency:     "real";
        width:            120px;
        location:         east;
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
    mainbox {
      children: [listview];
    }
  '';

  home.file.".yubico/authorized_yubikeys".text = "jma:cccccbeglknc:kvvcgcjdhudk";

  home.file.".local/share/rofi/themes/arc_dark_transparent_colors.rasi".text = ''
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

  xdg.configFile."i3/i3blocks.conf".text = ''
    # i3blocks config
    separator=false
    markup=pango

    [simple-2]
    full_text=: :
    color=#717171

    [disk]
    label=
    instance=/
    command=${pkgs.coreutils}/bin/df -h / | ${pkgs.gawk}/bin/awk '/\// {print $4}'
    interval=30

    [memory]
    label=
    command=${pkgs.procps}/bin/free -m | ${pkgs.gawk}/bin/awk '/^Mem:/ {printf "%.1f%%\n", $3/$2 * 100}'
    interval=2

    [cpu_usage]
    label=
    command=${pkgs.sysstat}/bin/mpstat 1 1 | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.gawk}/bin/awk '{print 100 - $NF "%"}'
    interval=2

    [temperature]
    label=
    command=${scripts.block-temperature}/bin/block-temperature
    interval=30

    [bandwidth]
    label=
    command=${scripts.block-bandwidth}/bin/block-bandwidth
    interval=5

    [battery]
    command=${scripts.block-battery}/bin/block-battery
    label=
    interval=30

    [simple-2]
    full_text=: :
    color=#717171

    [pavucontrol]
    full_text=
    command=${pkgs.pavucontrol}/bin/pavucontrol

    [volume-pulseaudio]
    command=${scripts.block-volume}/bin/block-volume
    instance=Master
    interval=1

    [pavucontrol-mic]
    full_text=🎤
    command=${pkgs.pavucontrol}/bin/pavucontrol

    [volume-mic]
    command=${scripts.block-volume}/bin/block-volume
    instance=Capture
    interval=1

    [simple-2]
    full_text=: :
    color=#717171

    [time]
    command=date '+%a %d %b %H:%M:%S'
    interval=1

    [simple-2]
    full_text=: :
    color=#717171
  '';

  home.keyboard = {
    layout = "us";
    variant = "altgr-intl";
    options = [ "caps:escape" ];
  };

  xsession = {
    enable = true;

    windowManager.i3 = {
      enable = true;
      config = {
        modifier = "Mod4";

        fonts = {
          names = [ "Noto Sans" ];
          style = "Regular";
          size = if pkgs.stdenv.hostPlatform.isAarch64 then 12.0 else 10.0;
        };

        gaps = {
          inner = 0;
          outer = 0;
        };

        keybindings = lib.mkOptionDefault {
          "Mod4+1" = "workspace number 1";
          "Mod4+2" = "workspace number 2";
          "Mod4+3" = "workspace number 3";
          "Mod4+4" = "workspace number 4";
          "Mod4+5" = "workspace number 5";
          "Mod4+6" = "workspace number 6";
          "Mod4+7" = "workspace number 7";
          "Mod4+8" = "workspace number 8";
          "Mod4+9" = "workspace number 9";

          "Mod4+Shift+1" = "move container to workspace number 1; workspace number 1";
          "Mod4+Shift+2" = "move container to workspace number 2; workspace number 2";
          "Mod4+Shift+3" = "move container to workspace number 3; workspace number 3";
          "Mod4+Shift+4" = "move container to workspace number 4; workspace number 4";
          "Mod4+Shift+5" = "move container to workspace number 5; workspace number 5";
          "Mod4+Shift+6" = "move container to workspace number 6; workspace number 6";
          "Mod4+Shift+7" = "move container to workspace number 7; workspace number 7";
          "Mod4+Shift+8" = "move container to workspace number 8; workspace number 8";
          "Mod4+Shift+9" = "move container to workspace number 9; workspace number 9";

          "Mod4+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "Mod4+Tab" = "exec ${scripts.zen-profile-selector}/bin/zen-profile-selector";

          "Mod4+space" = "exec --no-startup-id ${pkgs.i3}/bin/i3-dmenu-desktop --dmenu='${pkgs.dmenu}/bin/dmenu -i -fn \"Noto Sans-13\"'";
          "Mod4+p" = "exec ${pkgs.rofi-rbw}/bin/rofi-rbw --action type --target password";
          "Mod4+u" = "exec ${pkgs.rofi-rbw}/bin/rofi-rbw --action type --target username";

          "Mod4+Shift+q" = "kill";
          "Mod4+r" = "mode \"resize\"";

          "Mod4+h" = "focus left";
          "Mod4+j" = "focus down";
          "Mod4+k" = "focus up";
          "Mod4+l" = "focus right";

          "Mod4+Shift+h" = "move left";
          "Mod4+Shift+j" = "move down";
          "Mod4+Shift+k" = "move up";
          "Mod4+Shift+l" = "move right";

          "Mod4+b" = "workspace back_and_forth";
          "Mod4+Shift+b" = "move container to workspace back_and_forth; workspace back_and_forth";

          "Mod4+minus" = "split toggle";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+w" = "layout tabbed";
          "Mod4+Shift+space" = "floating toggle";
          "Mod4+Shift+f" = "floating toggle";
          "Mod4+Shift+s" = "sticky toggle";

          "Mod4+Shift+comma" = "move scratchpad";
          "Mod4+comma" = "scratchpad show";

          "XF86MonBrightnessUp" = "exec ${pkgs.xbacklight}/bin/xbacklight -inc 1";
          "XF86MonBrightnessDown" = "exec ${pkgs.xbacklight}/bin/xbacklight -dec 1";

          "XF86AudioRaiseVolume" =
            "exec --no-startup-id ${scripts.volume-brightness}/bin/volume-brightness volume_up";
          "XF86AudioLowerVolume" =
            "exec --no-startup-id ${scripts.volume-brightness}/bin/volume-brightness volume_down";
          "XF86AudioMute" =
            "exec --no-startup-id ${scripts.volume-brightness}/bin/volume-brightness volume_mute";

          "Mod4+Escape" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock";
        };

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

        assigns = {
          "2" = [
            { class = "^(?i)firefox$"; }
            { class = "^Brave-browser$"; }
            { class = "^zen-beta$"; }
          ];
          "4" = [
            { class = "^xfreerdp$"; }
            { class = "^steam$"; }
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

        window.commands = [
          {
            command = "floating enable";
            criteria = { class = "xfreerdp"; };
          }
          {
            command = "floating enable";
            criteria = { class = "Qalculate-gtk"; };
          }
          {
            command = "resize set 800 600";
            criteria = { class = "zoom"; };
          }
          {
            command = "floating enable";
            criteria = { class = "pavucontrol"; };
          }
          {
            command = "border pixel 1";
            criteria = { class = "^.*"; };
          }
        ];

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

        bars = [
          {
            position = "bottom";
            statusCommand = "${pkgs.i3blocks}/bin/i3blocks -c ${config.xdg.configHome}/i3/i3blocks.conf";
            fonts = {
              names = [ "Noto Sans" ];
              size = if pkgs.stdenv.hostPlatform.isAarch64 then 13.0 else 10.0;
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
          {
            command = "--no-startup-id ${pkgs.spice-vdagent}/bin/spice-vdagent";
            notification = false;
          }
          {
            command = "env -u QT_STYLE_OVERRIDE -u QT_QPA_PLATFORMTHEME ${pkgs.owncloud-client}/bin/owncloud";
            notification = false;
          }
          {
            command = "${pkgs.feh}/bin/feh --bg-fill ${wallpaper}";
            notification = false;
          }
        ];
      };
    };
  };

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
    gtk4 = {
      theme = config.gtk.theme;
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=KvArcDark
  '';

  # Report a dark color scheme to the desktop portal so Qt6/GTK apps
  # (ownCloud) render dark.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # Zen: open the profile manager on fresh launch instead of auto-loading a
  # default profile. home-manager's firefox module hardcodes
  # StartWithLastProfile=1, so replace the generated profiles.ini symlink
  # with a copy set to 0.
  home.activation.zenProfileManager = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ini="$HOME/.config/zen/profiles.ini"
    if [ -L "$ini" ]; then
      tgt=$(readlink "$ini")
      rm "$ini"
      ${pkgs.gnused}/bin/sed 's/StartWithLastProfile=1/StartWithLastProfile=0/' "$tgt" > "$ini"
    fi
    # our real file makes HM back it up each run; drop the backup so it
    # never collides with itself on the next activation.
    rm -f "$ini.hm-backup"
  '';

  imports = [
    ./home-common.nix
    ../programs/copyq.nix
    ../programs/mangohud.nix
    ../programs/zen-browser.nix
    ../services/dunst.nix
  ];
}
