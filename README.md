# infra

Infrastructure Setup &amp; Configuration

## Setup machine

-  ```nix-shell -p git --run "git clone https://github.com/piquel-fr/infra ~"```
-  ```sh infra/setup.sh```

Remote update:
- ```nixos-rebuild switch --flake .#pi --target-host piquel@remote.piquel.fr --sudo --ask-sudo-password --no-reexec```
