{ pkgs, ... }:

{
  services.picom = {
    enable = true;
    backend = "glx";

    # Shadow settings
    shadow = true;
    shadowOffsets = [
      1
      1
    ];
    shadowOpacity = 0.3;
    shadowExclude = [
      "! name~=''"
      "name = 'Notification'"
      "name = 'Plank'"
      "name = 'Docky'"
      "name = 'Kupfer'"
      "name = 'xfce4-notifyd'"
      "name *= 'VLC'"
      "name *= 'compton'"
      "name *= 'picom'"
      "name *= 'Chromium'"
      "name *= 'Chrome'"
      "class_g = 'Firefox' && argb"
      "class_g = 'Conky'"
      "class_g = 'Kupfer'"
      "class_g = 'Synapse'"
      "class_g ?= 'Notify-osd'"
      "class_g ?= 'Cairo-dock'"
      "class_g ?= 'Xfce4-notifyd'"
      "class_g ?= 'Xfce4-power-manager'"
      "class_g ?= 'Dmenu'"
      "class_g ?= 'i3-frame'"
      "_GTK_FRAME_EXTENTS@:c"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    ];

    # Opacity settings
    activeOpacity = 1.0;
    inactiveOpacity = 1.0;

    # Fading
    fade = false;
    fadeDelta = 1;
    fadeSteps = [
      0.03
      0.03
    ];
    fadeExclude = [ ];

    # Other settings
    vSync = false;

    settings = {
      # GLX backend settings
      glx-no-stencil = true;
      glx-copy-from-front = false;

      # Shadow settings (additional)
      shadow-radius = 5;
      shadow-ignore-shaped = false;

      # Opacity settings (additional)
      frame-opacity = 1.0;
      inactive-opacity-override = false;

      # Blur settings
      blur-background-fixed = false;
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      # Focus and detection
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      use-ewmh-active-win = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      detect-client-leader = true;

      # Performance
      refresh-rate = 0;
      unredir-if-possible = true;

      # XSync for nvidia
      xrender-sync-fence = true;

      # Window type settings
      wintypes = {
        tooltip = {
          fade = true;
          shadow = false;
          opacity = 0.85;
          focus = true;
        };
        fullscreen = {
          fade = true;
          shadow = false;
          opacity = 1.0;
          focus = true;
        };
      };

      # Focus exclude
      focus-exclude = [
        "class_g = 'Cairo-clock'"
      ];
    };
  };
}
