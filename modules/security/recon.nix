{
  # Reconnaissance tools for coursework: port scanning, DNS lookup, subdomain enumeration,
  # HTTP probing, content discovery and web fingerprinting. Promoted from the catalog once
  # they were in use, same pattern as wireless-audit.nix.
  flake.modules.nixos.recon = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nmap
      dnsutils # provides dig
      whatweb
      ffuf
      katana
      subfinder
      assetfinder
      findomain
      httpx
    ];
  };
}
