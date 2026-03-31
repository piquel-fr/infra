{ inputs, config, ... }:
{
    boot.loader.raspberry-pi.bootloader = "kernel";

    networking = {
        hostName = "piquel-pi";
        firewall.allowedTCPPorts = [ 7854 ];
        networkmanager.enable = true;
        nameservers = [
            "1.1.1.1"
                "1.0.0.1"
        ];
    };

    time.timeZone = "Europe/Paris";

    console.keyMap = "fr";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
    };

    system = {
        stateVersion = "25.11";
        userActivationScripts.zshrc = "touch .zshrc";
        autoUpgrade.enable = true;
        autoUpgrade.dates = "daily";
        nixos.tags =
        let
            cfg = config.boot.loader.raspberry-pi;
        in
        [
            "raspberry-pi-${cfg.variant}"
                cfg.bootloader
                config.boot.kernelPackages.kernel.version
        ];
    };

    nix = {
        gc = {
            automatic = true;
            options = "--delete-older-than 10d";
            dates = "weekly";
        };
        settings = {
            auto-optimise-store = true;
            experimental-features = [ "nix-command" "flakes" ];
            trusted-users = [ "root" "@wheel" "piquel" ];
        };
    };

    nixpkgs.overlays = [ inputs.dotfiles.overlays.additions ];
}
