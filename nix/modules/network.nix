# Manages the networking
{ ... }:
{
  flake.nixosModules.network =
    { ... }:
    {
      networking.firewall = {
        enable = true;

        # No public TCP/UDP ports. All legitimate traffic arrives via tailscale0,
        # which is already trusted unconditionally by the base module.
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
        # (Tailscale's own UDP port is opened by the base module.)

        # Swarm ports are only needed on the tailscale0 interface.
        # We open them here so NixOS's firewall doesn't block swarm gossip
        # arriving from other tailnet peers, then restrict via interface below.
        interfaces."tailscale0" = {
          allowedTCPPorts = [
            2377 # swarm cluster management
            7946 # container network discovery
          ];
          allowedUDPPorts = [
            7946 # container network discovery
            4789 # overlay network (VXLAN)
          ];
        };
      };

      # --- Network hardening ------------------------------------------------ #
      # Enable SYN cookies to resist SYN flood attacks.
      boot.kernel.sysctl = {
        "net.ipv4.tcp_syncookies" = 1;
        # Do not accept ICMP redirects (prevents MITM attacks).
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        # Do not send ICMP redirects.
        "net.ipv4.conf.all.send_redirects" = 0;
      };
    };
}
