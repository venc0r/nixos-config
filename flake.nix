{
  inputs = {
    # TEMP: pinned to fix commit for helm 4.2.0 (nixpkgs PR #530312, merged 2026-06-12). Revert to "nixos-unstable" once channel advances past this commit.
    nixpkgs.url = "github:NixOS/nixpkgs/93271e22bcf9e7b575be78636cdd9c2604ebb50b";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Sibling repo on disk. Clone first: git clone ssh://git@git.v3nc.org:2223/devOops/nixos-config-private.git ~/Documents/git/forgejo/nixos-config-private
    # Bootstrap without it: mkdir -p /tmp/stub && touch /tmp/stub/{hosts,ssh_config}
    #   sudo darwin-rebuild switch --flake '.#MacBook-Pro-von-Jorg' --override-input nixos-config-private 'path:/tmp/stub'
    nixos-config-private = {
      url = "path:/Users/jmarkert/Documents/git/forgejo/nixos-config-private";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, nix-darwin, ... }@inputs:
    let
      x86System = "x86_64-linux";
      armSystem = "aarch64-linux";
      darwinSystem = "aarch64-darwin";
      nurOverlay = { nixpkgs.overlays = [ inputs.nur.overlays.default ]; };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            system = armSystem;
            inherit inputs;
          };
          modules = [
            ./hosts/nixos/configuration.nix
            nurOverlay
          ];
        };
        cubi = nixpkgs.lib.nixosSystem {
          specialArgs = {
            system = x86System;
            inherit inputs;
          };
          modules = [
            ./hosts/cubi/configuration.nix
            nurOverlay
          ];
        };
      };

      homeConfigurations = {
        "jma@wsl" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = x86System;
            config.allowUnfree = true;
            config.permittedInsecurePackages = [ "python3.13-ecdsa-0.19.2" ];
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/home-wsl.nix ];
        };
      };

      darwinConfigurations =
        {
          "MacBook-Pro-von-Jorg" = nix-darwin.lib.darwinSystem {
            system = darwinSystem;
            specialArgs = { inherit inputs; };
            modules = [
              ./hosts/darwin/configuration.nix
              nurOverlay
            ];
          };
          "MacBook-Pro-von-Jorg-upgrade" = nix-darwin.lib.darwinSystem {
            system = darwinSystem;
            specialArgs = { inherit inputs; };
            modules = [
              ./hosts/darwin/configuration.nix
              nurOverlay
              ({ lib, ... }: {
                homebrew.onActivation = {
                  autoUpdate = lib.mkForce true;
                  upgrade = lib.mkForce true;
                  cleanup = lib.mkForce "uninstall";
                };
              })
            ];
          };
        };
    };
}
