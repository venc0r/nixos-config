{ config, pkgs, inputs, ... }:
{
  imports = [ inputs.himmelblau.nixosModules.himmelblau ];

  environment.systemPackages = [
    config.services.himmelblau.package
  ];

  services.himmelblau = {
    enable = true;
    package = inputs.himmelblau.packages.${pkgs.system}.himmelblau-desktop;
    settings = {
      # TODO: Update with actual Entra ID domain once confirmed
      domain = "cloudpunks.onmicrosoft.com";
      
      # TODO: Add Entra ID group GUIDs once available
      # pam_allow_groups = [ "ENTRA-GROUP-GUID-HERE" ];
      
      # Entra ID users will be automatically added to these local groups
      local_groups = [ "wheel" "docker" "networkmanager" ];
    };
  };
}
