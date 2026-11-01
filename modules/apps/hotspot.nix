{
  # Tools for the Network Toolkit hotspot: create_ap (from linux-wifi-hotspot) runs the access
  # point, hostapd is its access-point daemon, dnsmasq gives clients their addresses, and
  # qrencode draws the QR code for joining. None of these run as services, so nothing here
  # touches NetworkManager until the hotspot is turned on.
  flake.modules.nixos.hotspot = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      linux-wifi-hotspot
      hostapd
      dnsmasq
      qrencode
    ];
  };
}
