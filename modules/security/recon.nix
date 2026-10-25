{
  # Reconnaissance tools: port scanning, subdomain enumeration and HTTP probing.
  # Promoted out of the security-tools.nix catalog once actually used (nmap came
  # over after the CTF), same pattern as wireless-audit.nix.
  flake.modules.nixos.recon = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nmap
      subfinder
      assetfinder
      findomain
      httpx
    ];
  };
}
