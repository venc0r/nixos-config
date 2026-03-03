{ config, pkgs, inputs, lib, ... }:
{
  imports = [ inputs.himmelblau.nixosModules.himmelblau ];

  environment.systemPackages = [
    config.services.himmelblau.package
  ];

  services.himmelblau = {
    enable = true;
    package = lib.mkForce inputs.himmelblau.packages.${pkgs.stdenv.hostPlatform.system}.himmelblau-desktop;
    settings = {
      domain = [ "cloudpunks.de" ];

      # TODO: Add Entra ID group GUIDs once available
      # pam_allow_groups = [ "ENTRA-GROUP-GUID-HERE" ];

      local_groups = [ "wheel" "docker" "networkmanager" ];
    };
  };
}
