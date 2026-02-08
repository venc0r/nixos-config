{ config, pkgs, ... }:

{
  # Autorandr - automatic display configuration for cubi host
  #
  # To add a new profile:
  # 1. Connect your monitors in the desired configuration
  # 2. Run: autorandr --save <profile-name>
  # 3. Run: cat ~/.config/autorandr/<profile-name>/setup
  #    Copy the EDID fingerprints to the fingerprint section below
  # 4. Run: cat ~/.config/autorandr/<profile-name>/config
  #    Copy the display settings to the config section below
  # 5. Rebuild your system: sudo nixos-rebuild switch --flake .#cubi
  #
  programs.autorandr = {
    enable = true;

    profiles = {
      # Office setup: 2560x1440 external + laptop screen
      buero = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0006af9bfa00000000001f0104a51e137803aeac93585991281d505400000001010101010101010101010101010101fa3c80b870b0244010103e002dbc100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343055414e30332e32200a00dc";
          DP-1-8 = "00ffffffffffff0026cd5a6601060000151f0104a53c22783a0c95ab554ca0240d5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739323132313031353337000000fd00314c1e781e000a202020202020000000fc00504c32373932514e0a20202020011602031cf14f90050403020111121314060715161f2309070783010000023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000098";
          None-1-1 = "--CONNECTED-BUT-EDID-UNAVAILABLE--None-1-1";
          DP-1-1 = "00ffffffffffff0026cd5866f406000014200104a53c22783a0c95ab554ca0240d5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739323232303031373830000000fd00314c1e781e000a202020202020000000fc00504c32373932514e0a20202020012502031cf14f90050403020111121314060715161f2309070783010000023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000098";
        };
        config = {
          DP-1-8 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "1920x0";
            mode = "2560x1440";
            rate = "59.95";
          };
          eDP-1 = {
            enable = true;
            crtc = 1;
            position = "0x240";
            mode = "1920x1200";
            rate = "60.03";
          };
          HDMI-1.enable = false;
          DP-1.enable = false;
          DP-2.enable = false;
          DP-3.enable = false;
          DP-4.enable = false;
          DP-1-1.enable = false;
          None-1-1.enable = false;
        };
      };

      # Desktop setup: 4K@120Hz external + laptop screen
      desktop = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0006af9bfa00000000001f0104a51e137803aeac93585991281d505400000001010101010101010101010101010101fa3c80b870b0244010103e002dbc100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343055414e30332e32200a00dc";
          DP-3 = "00ffffffffffff001c540432370600002f210104b54627783be1b5ad5045a0250d5054bfcf00814081809500714f81c0b300d1c001014dd000a0f0703e8030203500b9882100001a000000ff003233343731423030313539310a000000fd003090ffff86010a202020202020000000fc004769676162797465204d33325502ca02033cf156010304131f120211900f0e1d1e60610514765d5e5f2f23090707830100006d1a0000020b30900005653c653ce305c301e6060501656512565e00a0a0a0295030203500b9882100001a8a6f80a0703840403020280cb9882100001a6fc200a0a0a0555030203500b9882100001a00000000000000000000000000bf70127900000301649a080204ff0e9f002f801f006f08990002000400ceac0104ff0e9f002f801f006f087e0002000400d0500104ff0e9f0010003e006f08270014000700fb7e00047f07870017001f003704110002000400f7e30004ff099f0007001f009f053100180007000000000000000000000000000000000000005890";
        };
        config = {
          DP-3 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "1920x0";
            mode = "3840x2160";
            rate = "120.00";
          };
          eDP-1 = {
            enable = true;
            crtc = 1;
            position = "0x610";
            mode = "1920x1200";
            rate = "60.03";
          };
          HDMI-1.enable = false;
          DP-1.enable = false;
          DP-2.enable = false;
          DP-4.enable = false;
        };
      };

      # Notebook only: Just laptop screen
      notebook = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0006af9bfa00000000001f0104a51e137803aeac93585991281d505400000001010101010101010101010101010101fa3c80b870b0244010103e002dbc100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343055414e30332e32200a00dc";
        };
        config = {
          eDP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1200";
            rate = "60.03";
          };
          HDMI-1.enable = false;
          DP-1.enable = false;
          DP-2.enable = false;
          DP-3.enable = false;
          DP-4.enable = false;
        };
      };
    };
  };
}
