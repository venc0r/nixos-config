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

  # Import the shared home-manager configuration
  home-manager.users.jma = import ../home.nix;
}
