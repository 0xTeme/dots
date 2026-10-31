{
  flake.modules.nixos.network = { pkgs, ... }: {
    networking.networkmanager.enable = true;

    # Loose reverse-path filtering lets replies return through the WireGuard tunnel used
    # for CTF VPNs. It is slightly weaker against spoofed source addresses than the strict
    # default, which is why it's set explicitly here rather than left implicit.
    networking.firewall.checkReversePath = "loose";

    environment.systemPackages = [ pkgs.wireguard-tools ];
  };
}
