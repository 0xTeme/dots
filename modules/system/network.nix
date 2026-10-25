{
  flake.modules.nixos.network = { pkgs, ... }: {
    networking.networkmanager.enable = true;
    networking.firewall.checkReversePath = "loose";

    environment.systemPackages = [ pkgs.wireguard-tools ];
  };
}
