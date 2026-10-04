{
  flake.modules.nixos.power = { pkgs, ... }: {
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    environment.systemPackages = [ pkgs.powertop ];
  };
}
