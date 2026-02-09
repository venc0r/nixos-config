{ config, pkgs, inputs, ... }:
{
  imports = [ inputs.himmelblau.nixosModules.himmelblau ];

  environment.systemPackages = [
    config.services.himmelblau.package
  ];

  services.himmelblau = {
    enable = true;
    # NOTE: Uncomment to use desktop variant with O365 suite and Teams
    # package = inputs.himmelblau.packages.${pkgs.system}.himmelblau-desktop;
    settings = {
      # TODO: Update with actual Entra ID domain once confirmed
      # Note: domain is a list to support multiple domains
      domain = [ "cloudpunks.onmicrosoft.com" ];
      
      # TODO: Add Entra ID group GUIDs once available
      # pam_allow_groups = [ "ENTRA-GROUP-GUID-HERE" ];
      
      # Entra ID users will be automatically added to these local groups
      local_groups = [ "wheel" "docker" "networkmanager" ];
    };
  };
}
