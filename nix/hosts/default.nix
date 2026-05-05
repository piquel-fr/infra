{ self, inputs, ... }:
let
  hosts = import ./hosts.nix;

  mkHost =
    hostName: isPi:
    let
      lib = if isPi then inputs.nixos-raspberrypi.lib else inputs.nixpkgs.lib;
    in
    lib.nixosSystem {
      modules = [
        # Global modules available on every host
        self.nixosModules.secrets
        self.nixosModules.tailscale
        self.nixosModules.network

        # Host-specific config
        ./${hostName}/hardware-configuration.nix

        # Some basic settings
        {
          networking.hostName = hostName;
          system.stateVersion = "25.11";
        }
      ];
    };
in
{
  flake.nixosConfigurations = builtins.listToAttrs (
    map (host: {
      name = host.hostname;
      value = mkHost host.hostname host.isPi;
    }) hosts
  );

  perSystem =
    { system, ... }:
    let
      mkNode = hostName: tailscaleIp: nixosConfig: {
        hostname = tailscaleIp; # deploy over Tailscale — no public SSH needed

        # deploy-rs will activate, then wait up to 30s for an SSH heartbeat.
        # If the machine goes silent (e.g. bad firewall rule) it rolls back.
        magicRollback = true;
        autoRollback = true;

        profiles.system = {
          sshUser = "deploy"; # see: modules/deploy-user.nix
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos nixosConfig;
        };
      };
    in
    {
      deploy.nodes = builtins.listToAttrs (
        map (host: {
          name = host.hostname;
          value = mkNode host.hostname host.ip self.nixosConfigurations.${host.hostname};
        }) hosts
      );

    };
}
