echo wakeonlan D8:BB:C1:DB:C6:FD > ~/start.sh
chmod +x ~/start.sh
cd ~/infra ||
cp /etc/nixos/hardware-configuration.nix nix/
sudo nixos-rebuild switch --flake .#pi
