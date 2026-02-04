{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.hostName is set in per-host configuration
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
    displayManager.sddm = {
      enable = true;
    };
  };

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
        ];
      };
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      # We assume home.nix is in the same directory as the host config
      # But since we moved this to common, we need to be careful about paths.
      # Ideally home.nix should also be common or passed as an argument.
      # For now, let's point to a common home.nix or handle this carefully.
      # The original code was: "jma" = import ./home.nix;

      # Since home.nix is currently inside hosts/nixos/home.nix and hosts/cubi/home.nix,
      # we need to decide if we centralize home.nix too.
      # For this step, I will point to the one in hosts/nixos as a temporary common,
      # OR we can leave the home-manager block in the per-host config?

      # DECISION: I will comment this out here and suggest we keep the home-manager
      # import in the per-host file for a moment, OR I can fix the path.
      # Let's keep it in common but use a relative path that works if we move home.nix too.
      # actually, let's try to reference the one in the host directory.
      # "jma" = import ./home.nix; <- This won't work if common.nix is in hosts/common.nix

      # Let's temporarily REMOVE the user import from here and put it back in the host config
      # to avoid path breakage until we decide where home.nix lives.
    };
  };

  # REVISION: To keep it simple, I will keep home-manager generic settings here,
  # but the actual 'users.jma = import ...' line I will put in the host config for now
  # to avoid "file not found" errors.

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
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
