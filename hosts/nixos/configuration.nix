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

  home-manager.users.jma = {
    imports = [ ../home.nix ];
    home.username = lib.mkDefault "jma";
    home.homeDirectory = lib.mkDefault "/home/jma";
  };

  home-manager.users."jmarkert@cloudpunks.de" = {
    imports = [ ../home.nix ];
    home.username = lib.mkForce "jma@cloudpunks.de";
    home.homeDirectory = lib.mkForce "/home/jma@cloudpunks.de";
  };
}
