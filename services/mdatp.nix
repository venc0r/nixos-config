{ config, pkgs, inputs, lib, ... }:
{
  imports = [ inputs.mdatp.nixosModules.mdatp ];

  services.mdatp = {
    enable = true;
  };
}
