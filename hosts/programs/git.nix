{ lib, config, pkgs, ... }:
let

in
{
  programs.git = {
    enable = true;
    settings.user = {
      Email = "venc0r@live.com";
      Name = "Jörg Markert";
    };
  };
}
