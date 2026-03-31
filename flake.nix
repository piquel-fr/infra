{
    description = "piquel-pi system configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
        piqueld = {
            url = "github:piquel-fr/piqueld";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-raspberrypi = {
            url = "github:nvmd/nixos-raspberrypi/main";
            #inputs.nixpkgs.follows = "nixpkgs";
        };
        dotfiles = {
            url = "github:PiquelChips/dotfiles";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.piqueld.follows = "piqueld";
        };
    };

    nixConfig = {
        extra-substituters = [
            "https://nixos-raspberrypi.cachix.org"
        ];
        extra-trusted-public-keys = [
            "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
        ];
    };

    outputs = { self, nixos-raspberrypi, ... }@inputs:
    let
        inherit (self) outputs;
    in
    {
        nixosConfigurations = {
            pi = nixos-raspberrypi.lib.nixosSystem {
                specialArgs = { inherit inputs outputs nixos-raspberrypi; };
                modules = [ ./nix/configs/pi ];
            };
        };
    };
}
