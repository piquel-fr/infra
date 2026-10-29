# The host registry: every machine this repo manages. Each `hosts.<name>` entry
# becomes `nixosConfigurations.<name>` and the deploy-rs node `deploy.nodes.<name>`.
{
  lib,
  config,
  inputs,
  self,
  ...
}:
let
  inherit (lib) mkOption types;

  # Modules every host imports.
  common = with self.nixosModules; [
    base
    admin
    network
    secrets
    tailscale
  ];

  # deploy-rs's library, with nixpkgs' prebuilt deploy-rs as the activation
  # tool. The flake's own would be compiled, under emulation for other platforms.
  deployLib =
    system:
    (import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.deploy-rs.overlays.default
        (final: prev: {
          deploy-rs = {
            inherit (inputs.nixpkgs.legacyPackages.${system}) deploy-rs;
            inherit (prev.deploy-rs) lib;
          };
        })
      ];
    }).deploy-rs.lib;

  host = types.submodule {
    options = {
      system = mkOption {
        type = types.str;
        description = "The host's platform, such as `x86_64-linux`.";
      };
      address = mkOption {
        type = types.str;
        description = "The address deploy-rs connects to over SSH.";
      };
      nixosSystem = mkOption {
        type = types.functionTo types.raw;
        default = inputs.nixpkgs.lib.nixosSystem;
        defaultText = lib.literalExpression "inputs.nixpkgs.lib.nixosSystem";
        description = "Builds the host's configuration. Raspberry Pis use nixos-raspberrypi's.";
      };
      module = mkOption {
        type = types.deferredModule;
        description = "The host's own NixOS configuration.";
      };
    };
  };
in
{
  options.hosts = mkOption {
    type = types.attrsOf host;
    default = { };
    description = "Machines managed by this repo, by hostname.";
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      name: host:
      host.nixosSystem {
        modules = common ++ [
          host.module
          {
            networking.hostName = name;
            nixpkgs.hostPlatform = host.system;
          }
        ];
      }
    ) config.hosts;

    flake.deploy.nodes = lib.mapAttrs (name: host: {
      hostname = host.address;
      # After activating, deploy-rs waits for an SSH heartbeat and rolls back if
      # the host stops answering, such as after a bad firewall rule.
      magicRollback = true;
      autoRollback = true;
      profiles.system = {
        sshUser = config.admin;
        user = "root";
        path = (deployLib host.system).activate.nixos self.nixosConfigurations.${name};
      };
    }) config.hosts;

    perSystem =
      { system, ... }:
      {
        # Only this platform's nodes: another platform's would build its whole system.
        checks = (deployLib system).deployChecks {
          nodes = lib.filterAttrs (name: _: config.hosts.${name}.system == system) self.deploy.nodes;
        };
      };
  };
}
