# The operator's account on every host. deploy-rs connects as it.
{ lib, config, ... }:
let
  user = config.admin;
in
{
  options.admin = lib.mkOption {
    type = lib.types.str;
    default = "piquel";
    description = "The operator's user name on every host.";
  };

  config.flake.nixosModules.admin = {
    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVqRluVYJXXoNYyFQzkZm2v2bRnAv/PNuoLRr2G2/Dv piquel@piquel.fr"
      ];
    };

    # deploy-rs activates through sudo without a terminal, so the operator's SSH
    # key is the root credential.
    security.sudo.wheelNeedsPassword = false;
    # deploy-rs copies closures to the host as this user.
    nix.settings.trusted-users = [ user ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
