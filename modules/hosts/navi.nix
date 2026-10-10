{ config, inputs, ... }:
{
  # The host is just a list of features. Remove a line to remove a feature.
  flake.nixosConfigurations.navi = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      navi
      navi-hardware
      boot
      nix-settings
      network
      locale
      fonts
      audio
      power
      disks
      security
      base-packages
      pavucontrol
      security-tools
      screen-recorder
      docker
      wireless-audit
      teme
      niri
      xwayland
      greeter
      noctalia
      input-method
      cursor
      foot
      telegram
      libreoffice
      nix-ld
    ];
  };

  flake.modules.nixos.navi = {
    networking.hostName = "navi";
    system.stateVersion = "26.05";
  };
}
