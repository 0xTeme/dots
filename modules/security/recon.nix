{
  # Reconnaissance tools for coursework: port scanning, DNS lookup, subdomain enumeration,
  # HTTP probing, content discovery, web fingerprinting and WAF detection. Promoted from
  # the catalog once they were in use, same pattern as wireless-audit.nix.
  flake.modules.nixos.recon = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Port scanning and DNS
      nmap
      dnsutils # provides dig

      # Subdomain enumeration and HTTP probing
      subfinder
      assetfinder
      findomain
      httpx

      # Web fingerprinting and content discovery
      whatweb
      wafw00f
      ffuf
      katana
    ];
  };
}
