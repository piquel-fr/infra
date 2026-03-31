{ inputs, nixos-raspberrypi, pkgs, ... }:
{
    imports = with nixos-raspberrypi.nixosModules; [
        ./system.nix
        ./piqueld.nix

        inputs.dotfiles.nixosModules.tmux
        inputs.dotfiles.nixosModules.zsh
        #inputs.dotfiles.nixosModules.nvim

        raspberry-pi-5.base
        raspberry-pi-5.page-size-16k
        raspberry-pi-5.bluetooth
        ./hardware-configuration.nix
    ];

    # USER CONFIGURATION

    users.defaultUserShell = pkgs.zsh;

    users.users.piquel = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "docker" "piqueld" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
            wakeonlan
        ];
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVqRluVYJXXoNYyFQzkZm2v2bRnAv/PNuoLRr2G2/Dv piquel@piquel.fr"
        ];
    };

    # GLOBAL CONFIGURATION

    environment = {
        shells = with pkgs; [ zsh ];
        variables = {
            LANG = "en_US.UTF-8";
            EDITOR = "vim";
        };
        systemPackages = with pkgs; [
            zsh neovim zip unzip tree fd fzf file
        ];
    };

    virtualisation.docker.enable = true;

    # PROGRAMS AND SERVICES

    programs = {
        git = {
            enable = true;
            lfs.enable = true;
            config = {
                init.defaultBranch = "main";
                core.editor = "vim";
                user = {
                    name = "piquel";
                    email = "piquel@piquel.fr";
                };
                url = {
                    "git@github.com:" = {
                        insteadOf = [ "https://github.com/" ];
                    };
                };
                filter."lfs" = {
                    clean = "git-lfs clean -- %f";
                    smudge = "git-lfs smudge -- %f";
                    process = "git-lfs filter-process";
                    required = true;
                };
            };
        };
    };

    services = {
        zsh.enable = true;
        tmux.enable = true;
        openssh = {
            enable = true;
            settings = {
                UsePAM = false;
                PasswordAuthentication = false;
                PermitRootLogin = "no";
            };
        };
        #nvim.enable = true;
    };
}
