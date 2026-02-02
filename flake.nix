{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, ... } @ inputs:
        let
            system = "x86_64-linux";
	    pkgs = import nixpkgs {
                inherit system;
                config = { allowUnfree = true; };
            };
        in
            {
            nixosConfigurations = {
                nixos = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; inherit inputs; };
                    modules = [
                        ./hosts/nixos/configuration.nix
 			inputs.home-manager.nixosModules.default
                    ];
                };
                cubi = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; inherit inputs; };
                    modules = [
                        ./hosts/cubi/configuration.nix
 			inputs.home-manager.nixosModules.default
                    ];
                };
            };
        };
}
