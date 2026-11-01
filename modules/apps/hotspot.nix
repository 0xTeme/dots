{
  # Tools for the hotspot plugins: create_ap (from linux-wifi-hotspot) runs the access point,
  # hostapd is its access-point daemon, dnsmasq gives clients their addresses, and qrencode
  # draws the QR code for joining. None of these run as services, so nothing here touches
  # NetworkManager until the hotspot is turned on.
  flake.modules.nixos.hotspot = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      linux-wifi-hotspot
      hostapd
      dnsmasq
      qrencode
    ];

    # Share WiFi hardcodes the interface name wlan0, but the Intel driver names this card
    # wlp108s0. This rule names the card wlan0 when it loads. NetworkManager matches networks
    # by name, not interface, so saved networks, the VPN and the USB tether are unaffected.
    # Removing this rule undoes the change.
    services.udev.extraRules = ''
      SUBSYSTEM=="net", ACTION=="add", DRIVERS=="iwlwifi", NAME="wlan0"
    '';
  };
}
