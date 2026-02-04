{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
          };
          modules = [
            ./hosts/nixos/configuration.nix
          ];
        };
        cubi = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
          };
          modules = [
            ./hosts/cubi/configuration.nix
          ];
        };
      };
    };
}
