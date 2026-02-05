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
    feh # Wallpaper
    picom # Compositor
    xorg.xbacklight
    # dunst # Configured via services.dunst
    pavucontrol # Audio control
    pasystray
    networkmanagerapplet
    autorandr # Display management
    arandr # GUI for xrandr
    flameshot # Screenshots
    copyq
    polkit_gnome

    # System monitoring
    sysstat
    lm_sensors
    acpi
    iproute2

    # Applications mentioned in config
    # alacritty # Configured via programs.alacritty
    # zen-browser # Requires flake input or overlay
    # supersonic # Check exact package name (supersonic-wayland?)
    thunar
    discord
    qalculate-gtk

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
  ];

  home.file = {
    ".p10k.zsh".source = ./dotfiles/.p10k.zsh;
  };

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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "podman"
        "fzf"
        "git"
        "git-auto-fetch"
        "helm"
        "history-substring-search"
        "kubectl"
        "ssh-agent"
        "sudo"
        "terraform"
        "vi-mode"
        "history"
      ];
      custom = "$HOME/.oh-my-zsh/custom/";
    };
    historySubstringSearch.enable = true;
    prezto.ssh.identities = [
      "id_rsa"
      "id_rsa_venc"
    ];
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent =
      let
        zshConfigEarlyInit = lib.mkOrder 500 ''
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          source $HOME/.p10k.zsh
          if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi '';
        zshConfig = lib.mkOrder 1000 "# create my custom configs";
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfig
      ];
  };

  imports = [ ./programs/git.nix ];

  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [
        "~/.config/alacritty/gruvbox-dark.toml"
        # "~/.config/alacritty/gruvbox-light.toml"
      ];

      env = {
        TERM = "xterm-256color";
        WINIT_X11_SCALE_FACTOR = "1.5";
      };

      font = {
        size = 10.0;
        normal = {
          family = "MesloLGS NF";
          style = "Regular";
        };
        bold = {
          family = "MesloLGS NF";
          style = "Bold";
        };
        italic = {
          family = "MesloLGS NF";
          style = "Italic";
        };
        offset = {
          x = 0;
          y = 0;
        };
      };

      scrolling = {
        history = 1000;
        multiplier = 3;
      };

      selection = {
        semantic_escape_chars = "=,│`|:\"' ()[]{}<>";
      };

      window = {
        decorations = "none";
        opacity = 0.9;
        padding = {
          x = 2;
          y = 2;
        };
      };
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 2;
        follow = "mouse";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "0x0";
        scale = 0;
        notification_limit = 10;
        indicate_hidden = "yes";
        transparency = 30;
        separator_height = 0;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 1;
        frame_color = "#222222";
        separator_color = "frame";
        sort = "yes";
        idle_threshold = 120;
        font = "MesloLGS NF 8";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap = "yes";
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        icon_position = "left";
        min_icon_size = 0;
        max_icon_size = 32;
        icon_path = "/usr/share/icons/gnome/16x16/status/:/usr/share/icons/gnome/16x16/devices/";
        sticky_history = "yes";
        history_length = 20;
        dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst:";
        browser = "${pkgs.firefox}/bin/firefox -new-tab";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 0;
        ignore_dbusclose = false;
        force_xinerama = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      experimental = {
        per_monitor_dpi = false;
      };

      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };

      urgency_low = {
        background = "#222222";
        foreground = "#888888";
        timeout = 40;
      };

      urgency_normal = {
        background = "#759a1f";
        foreground = "#002b36";
        timeout = 60;
      };

      urgency_critical = {
        background = "#900000";
        foreground = "#ffffff";
        frame_color = "#ff0000";
        timeout = 0;
      };
    };
  };

  xdg.configFile."i3/i3blocks.conf".text = ''
    # i3blocks config
    separator=false
    markup=pango

    [simple-2]
    full_text=: :
    color=#717171

    [disk]
    label= 
    instance=/
    command=${pkgs.coreutils}/bin/df -h / | ${pkgs.gawk}/bin/awk '/\// {print $4}'
    interval=30

    [memory]
    label= 
    command=${pkgs.procps}/bin/free -m | ${pkgs.gawk}/bin/awk '/^Mem:/ {printf "%.1f%%\n", $3/$2 * 100}'
    interval=2

    [cpu_usage]
    label= 
    command=${pkgs.sysstat}/bin/mpstat 1 1 | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.gawk}/bin/awk '{print 100 - $NF "%"}'
    interval=2

    [temperature]
    label= 
    command=${scripts.block-temperature}/bin/block-temperature
    interval=30

    [bandwidth]
    label= 
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
    full_text=
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

  xsession.windowManager.i3 = {
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

        # Browser
        "Mod4+Tab" = "exec zen-browser --profileManager";

        # Kill window
        "Mod4+Shift+q" = "kill";

        # Menus
        "Mod4+space" = "exec --no-startup-id i3-dmenu-desktop";

        # Resize mode
        "Mod4+r" = "mode \"resize\"";

        # RBW / Rofi
        "Mod4+p" = "exec rofi-rbw --action type --target password";
        "Mod4+u" = "exec rofi-rbw --action type --target username";

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
        "XF86MonBrightnessUp" = "exec xbacklight -inc 1";
        "XF86MonBrightnessDown" = "exec xbacklight -dec 1";

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
          command = "${pkgs.xorg.setxkbmap}/bin/setxkbmap -option caps:escape";
          notification = false;
        }
        {
          command = "${pkgs.xorg.xset}/bin/xset r rate 250 70";
          notification = false;
        }
        {
          command = "autorandr --load desktop";
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
          command = "--no-startup-id ${pkgs.picom}/bin/picom --config ~/.config/picom.conf";
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
          command = "--no-startup-id copyq";
          notification = false;
        }
        {
          command = "--no-startup-id xautolock -time 10 -locker \"${scripts.blurlock}/bin/blurlock\"";
          notification = false;
        }
      ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
