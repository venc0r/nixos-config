{
  lib,
  config,
  pkgs,
  ...
}:

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
    dunst # Notifications
    pavucontrol # Audio control
    pasystray
    networkmanagerapplet
    autorandr # Display management
    arandr # GUI for xrandr
    flameshot # Screenshots
    copyq
    polkit_gnome

    # Applications mentioned in config
    alacritty
    # zen-browser # Requires flake input or overlay
    # supersonic # Check exact package name (supersonic-wayland?)
    thunar
    discord
    qalculate-gtk
  ];

  home.file = {
    ".p10k.zsh".source = ./dotfiles/.p10k.zsh;
  };

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

  programs.git = {
    enable = true;
    settings.user = {
      Email = "venc0r@live.com";
      Name = "Jörg Markert";
    };
  };

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

        # Volume (Referencing the script from original config - ensure it exists or replace with pactl)
        "XF86AudioRaiseVolume" = "exec --no-startup-id ~/.config/i3/scripts/volume_brightness.sh volume_up";
        "XF86AudioLowerVolume" =
          "exec --no-startup-id ~/.config/i3/scripts/volume_brightness.sh volume_down";
        "XF86AudioMute" = "exec --no-startup-id ~/.config/i3/scripts/volume_brightness.sh volume_mute";

        # Power Menu
        "Mod4+Shift+o" = "exec --no-startup-id ~/.config/i3/scripts/powermenu";

        # Lock
        "Mod4+Escape" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock";
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
          statusCommand = "i3blocks -c ~/.config/i3/i3blocks.conf";
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
          command = "--no-startup-id xautolock -time 10 -locker \"\${HOME}/.local/bin/scripts/blurlock\"";
          notification = false;
        }
      ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
