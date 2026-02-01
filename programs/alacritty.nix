{ lib, config, pkgs, ... }:
let

in
{
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [
        "~/.config/alacritty/gruvbox-dark.toml"
        # "~/.config/alacritty/gruvbox-light.toml"
      ];

      env = {
        TERM = "xterm-256color";
      } // lib.optionalAttrs pkgs.stdenv.isLinux {
        WINIT_X11_SCALE_FACTOR = if pkgs.stdenv.hostPlatform.isAarch64 then "2.0" else "1.5";
      } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isAarch64 {
        LIBGL_ALWAYS_SOFTWARE = "1";
      };

      font = {
        size = 11.0;
        normal = {
          family = "MesloLGS Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "MesloLGS Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "MesloLGS Nerd Font";
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

      keyboard.bindings = [
        { key = "="; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "-"; mods = "Control"; action = "DecreaseFontSize"; }
        { key = "0"; mods = "Control"; action = "ResetFontSize"; }
      ];

      window = {
        decorations = if pkgs.stdenv.isDarwin then "Buttonless" else "none";
        opacity = 0.9;
        option_as_alt = lib.mkIf pkgs.stdenv.isDarwin "Both";
        padding = {
          x = 2;
          y = 2;
        };
      };
    };
  };
}

