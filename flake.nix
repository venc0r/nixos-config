{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    himmelblau = {
      url = "github:himmelblau-idm/himmelblau/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mdatp = {
      url = "github:epetousis/nix-mdatp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
  { self, nixpkgs, home-manager, ... }@inputs:
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
    homeConfigurations."jmarkert@cloudpunks.de" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./hosts/home.nix
          ({ lib, ... }: {
           home.username = "jmarkert@cloudpunks.de";
           home.homeDirectory = "/home/jmarkert@cloudpunks.de";
           home.stateVersion = "24.11";
           })
      ];
    };
  };
}
