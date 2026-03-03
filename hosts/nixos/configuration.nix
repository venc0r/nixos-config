{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  networking.hostName = "nixos";

  home-manager.users.jma = {
    imports = [ ../home.nix ];
    home.username = lib.mkDefault "jma";
    home.homeDirectory = lib.mkDefault "/home/jma";
  };
}
