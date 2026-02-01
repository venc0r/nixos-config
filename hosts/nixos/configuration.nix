{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  networking.hostName = "nixos";

  boot.kernelParams = [
    "console=ttyAMA0,115200n8"
    "console=hvc0"
  ];

  # hvc0 is the serial console (for keychain LUKS injection). Keep kernel
  # console chatter minimal so it doesn't backpressure/stall the guest when
  # no host reader is draining the serial pty.
  boot.consoleLogLevel = 3;

  boot.initrd.availableKernelModules = [ "virtio_console" ];

  hardware.graphics.enable = true;

  services.spice-vdagentd.enable = true;

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --auto || true
  '';

  environment.systemPackages = [ pkgs.bitwarden-desktop ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "jma" ];
  };

  # Allow the 1Password browser extension to unlock via the desktop app
  # for Zen (Firefox-based, not in the default allowed list).
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      zen-beta
      .zen-wrapped
    '';
    mode = "0755";
  };

  # Secret Service keyring for GUI app credentials (ownCloud, NM wifi, etc).
  # Unlocked at graphical login via the LightDM PAM stack.
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # Firezone zero-trust client, tunnel terminates in the VM.
  services.resolved.enable = true;
  services.firezone.gui-client = {
    enable = true;
    allowedUsers = [ "jma" ];
    name = "nixos-dev-vm";
  };

  # mDNS so the VM is reachable as nixos.local (stable despite DHCP).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Desktop portal so Qt6/GTK apps (ownCloud) detect the dark color scheme.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # Home Manager configuration
  home-manager.users.jma.imports = [
    ../home.nix # Shared config
  ];
}
