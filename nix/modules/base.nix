# Settings shared by every host: locale, shell, tools and Nix itself.
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
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

      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;
      # Skip zsh's first-run wizard for users without a `.zshrc`.
      system.userActivationScripts.zshrc = "touch .zshrc";

      programs.git.enable = true;
      programs.tmux.enable = true;
      environment.variables.EDITOR = "nvim";
      environment.systemPackages = with pkgs; [
        neovim
        zip
        unzip
        tree
        fd
        fzf
        file
      ];

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 10d";
        };
      };
    };
}
