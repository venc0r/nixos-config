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
}

