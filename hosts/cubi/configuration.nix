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

  networking.hostName = "cubi";

  # Home Manager configuration
  home-manager.users.jma.imports = [
    ../home.nix # Shared config
    ./autorandr.nix # Host-specific display profiles
    ./packages.nix # Host-specific packages
    ../../services/picom.nix # Compositor (doesn't work well in VMs)
  ];
}
