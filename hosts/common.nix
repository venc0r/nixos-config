{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.default
    ../services/himmelblau.nix
    ../services/mdatp.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Show more verbose output during builds and downloads
  nix.extraOptions = ''
    show-trace = true
  '';

  # Increase download buffer for large packages (zoom, teams, etc)
  nix.settings.download-buffer-size = 268435456; # 256 MB (default is 64 MB)

  # Additional performance settings
  nix.settings = {
    # Use multiple cores for building
    max-jobs = "auto";
    cores = 0; # Use all available cores

    # Enable binary cache substitution
    substituters = [
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
    autoRepeatDelay = 250;
    autoRepeatInterval = 10;
  };

  security.loginDefs.settings.LOGIN_TIMEOUT = 300;

  # Enable dconf for GTK application settings
  programs.dconf.enable = true;

  # Define a user account.
  users.users.jma = {
    isNormalUser = true;
    description = "Joerg Markert";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
    openssh = {
      authorizedKeys = {
        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPuI7XTWodjRsAb4sNpPk/hlrVUlcWco8O/igRvIDFk2 jma"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOI50Wb3qAGyezwS9hNcpNiM7TZ04JNhVgZ87IKmpjMK2J67V9PD9qukC1fOJsRzC9ELWS0+hEMMtRHhFQYYKu/gUJVzzy6jMXE52eQ01PxHpVOtaUPjAAjSz80UkCyKBZfYWSWKQol5bHseFM4ifpGyhqqUrYyHy7sU+OWwiUhS08MqHUY3ML2RKf658I8OdvHDPY+otrCvGGVbOUj4S6NAX/WcIStVWvOb0lYX2QoTwdBDvk1BqBABiZokO4D7yPb+l4oODjAb3rF2JMkxU6T7kM9ez/9T+GKppoztsQ5ItKSxUuCX4CcId8V2Gly6kJtVImzD0sKyPVGXPOfIwR"
        ];
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    # User config is imported in per-host configuration
    users = { };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    alacritty
    xterm
    curl
    git
    fzf
    neovim
    vim
    zsh
    zsh-autosuggestions
    zsh-powerlevel10k
    wget
  ];

  programs.zsh.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
