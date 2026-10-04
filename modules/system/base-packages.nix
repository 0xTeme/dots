{
  flake.modules.nixos.base-packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      ripgrep
      pciutils
      usbutils
      file
      tree
      wl-clipboard
      brightnessctl
      smartmontools
    ];
  };
}
