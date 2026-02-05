{ lib, config, pkgs, ... }:
let

in
{
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
}
