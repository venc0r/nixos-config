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

  # Import the shared home-manager configuration
  home-manager.users.jma = import ../home.nix;
}
