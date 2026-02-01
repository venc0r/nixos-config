{
    inputs = {
        # This is pointing to an unstable release.
        # If you prefer a stable release instead, you can this to the latest number shown here: https://nixos.org/download
        # i.e. nixos-24.11
        # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = inputs@{ self, nixpkgs, ... }:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
                inherit system;
                config = {
                    allowUnfree = true;
                };
            };
        in
            {
            # NOTE: 'nixos' is the default hostname
            nixosConfigurations = {
                nixos = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
                    modules = [
                        ./nixos/configuration.nix
                    ];
                };
            };
        };
}
