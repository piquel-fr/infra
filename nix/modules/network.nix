# Manages the networking
{ ... }:
{
  flake.nixosModules.network =
    { ... }:
    {
      # Traffic from tailnet peers is trusted by the tailscale module. Publicly,
      # only SSH is open (openssh's default) until it moves to wg-infra (#3).
      networking.firewall.enable = true;

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
