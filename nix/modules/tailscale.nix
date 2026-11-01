{ ... }:
{
  flake.nixosModules.tailscale =
    { config, ... }:
    {
      services.tailscale = {
        enable = true;

        # Logs in with this key whenever the node is logged out or stopped at
        # boot. A registered, running node never uses it.
        authKeyFile = config.age.secrets.tailscale_auth.path;
      };

      networking.firewall = {
        # ------------------------------------------------------------------ #
        # Critical: let Tailscale packets through BEFORE nftables/iptables    #
        # drops them. Without this, the firewall boots before tailscaled and  #
        # the interface never comes up cleanly.                               #
        # ------------------------------------------------------------------ #
        checkReversePath = "loose";

        # Trust the tailscale0 interface so intra-mesh traffic is unrestricted.
        # All machines on the tailnet can freely reach each other.
        trustedInterfaces = [ "tailscale0" ];

        # Allow Tailscale's UDP port for NAT traversal / direct connections.
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      # Ensure tailscaled starts after the network is up.
      systemd.services.tailscaled = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    };
}
