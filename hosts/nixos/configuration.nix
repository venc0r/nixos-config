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

  # Home Manager configuration
  home-manager.users.jma.imports = [
    ../home.nix # Shared config
  ];
}
