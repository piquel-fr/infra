# The Raspberry Pi 5 at home.
{ config, inputs, ... }:
let
  admin = config.admin;
in
{
  hosts.piquel-pi = {
    system = "aarch64-linux";
    address = "100.96.91.58";
    nixosSystem = inputs.nixos-raspberrypi.lib.nixosSystem;
    module =
      { config, pkgs, ... }:
      {
        imports = with inputs.nixos-raspberrypi.nixosModules; [
          ./_hardware-configuration.nix
          raspberry-pi-5.base
          raspberry-pi-5.bluetooth
        ];

        boot.loader.raspberry-pi.bootloader = "kernel";
        system.nixos.tags =
          let
            cfg = config.boot.loader.raspberry-pi;
          in
          [
            "raspberry-pi-${cfg.variant}"
            cfg.bootloader
            config.boot.kernelPackages.kernel.version
          ];

        networking = {
          networkmanager.enable = true;
          nameservers = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };

        users.users.${admin} = {
          extraGroups = [ "networkmanager" ];
          packages = [ pkgs.wakeonlan ];
        };

        system.stateVersion = "25.11";
      };
  };
}
