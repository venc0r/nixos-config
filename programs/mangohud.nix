{ config, ... }:

{
  programs.mangohud = {
    enable = true;

    settings = {
      # Performance
      # fps_limit = 0;
      # vsync = 0;

      # GPU stats
      gpu_stats = true;
      gpu_temp = true;
      gpu_core_clock = true;
      gpu_mem_clock = true;
      gpu_power = true;
      gpu_load_change = true;
      gpu_load_value = [
        60
        90
      ];
      gpu_load_color = "39F900,FDFD09,B22222";

      # CPU stats
      cpu_stats = true;
      cpu_temp = true;
      cpu_power = true;
      cpu_text = "CPU";
      cpu_mhz = true;
      cpu_load_change = true;
      cpu_load_value = [
        60
        90
      ];
      cpu_load_color = "39F900,FDFD09,B22222";

      # Memory
      vram = true;
      ram = true;
      swap = true;

      # FPS
      fps = true;
      fps_sampling_period = 500;
      fps_color_change = true;
      fps_value = [
        30
        60
      ];
      fps_color = "B22222,FDFD09,39F900";
      frametime = true;

      # Frame timing graph
      frame_timing = true;

      # Visual
      background_alpha = 0.5;

      # Interaction (keybinds)
      toggle_hud = "Shift_R+F12";
      toggle_logging = "Shift_L+F2";

      # Logging
      output_folder = "${config.home.homeDirectory}/.mangologs";
    };
  };
}
