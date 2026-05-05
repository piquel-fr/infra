{ ... }:
{
  flake.nixosModules.deploy-user =
    { pkgs, ... }:

    {
      # The deploy user needs to be in the wheel group (for sudo)
      # but we restrict it to only the commands deploy-rs actually calls.
      users.users.deploy = {
        isSystemUser = true;
        group = "deploy";
        shell = pkgs.bash;
        # Add your SSH public key here (or manage via sops-nix).
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVqRluVYJXXoNYyFQzkZm2v2bRnAv/PNuoLRr2G2/Dv piquel@piquel.fr"
        ];
      };

      users.groups.deploy = { };

      security.sudo.extraRules = [
        {
          users = [ "deploy" ];
          commands = [
            # Allow deploy-rs to activate NixOS profiles without a password.
            {
              command = "/run/current-system/sw/bin/nix-env";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nix";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
              options = [ "NOPASSWD" ];
            }
            # deploy-rs magic-rollback writes a temporary activation script here:
            {
              command = "/bin/sh";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      # Harden SSH: disable password auth, only keys allowed.
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          # Only listen on the Tailscale interface — never on the public IP.
          # Deploy-rs connects via Tailscale, so this is safe.
          ListenAddress = "100.64.0.0/10"; # Tailscale CGNAT range
        };
      };
    }

  ;
}
