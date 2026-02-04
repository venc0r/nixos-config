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

  # We define the home-manager user here because the file is local to this directory
  home-manager.users.jma = import ./home.nix;
}
