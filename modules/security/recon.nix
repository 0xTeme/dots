{
  # Subdomain enumeration and HTTP probing tools.
  flake.modules.nixos.recon = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      subfinder
      assetfinder
      findomain
      httpx
    ];
  };
}
