{
  description = "piquel-pi system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    piqueld = {
      url = "github:piquel-fr/piqueld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:PiquelChips/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.piqueld.follows = "piqueld";
      inputs.agenix.follows = "agenix";
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

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
      ];
      imports = [
        ./nix
        ./nix/hosts
      ];
      perSystem =
        { system, pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
          checks = builtins.mapAttrs (_: inputs.deploy-rs.lib.${system}.deployChecks self.deploy) {
          };
        };

    };

}
