{
  flake.modules.nixos.libreoffice = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      libreoffice-fresh

      # Needed by Noctalia's LibreOffice theme hook.
      python3
      zip
    ];
  };
}
