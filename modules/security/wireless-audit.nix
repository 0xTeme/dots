{
  # Tools for wireless auditing, run directly (airmon-ng, reaver, bully, etc.), not
  # through airgeddon: its bundled reaver/wash build (v1.4) turned out too old for
  # reliable WPS scanning or Pixie Dust. Promoted out of the security-tools.nix
  # catalog once actually adopted, same pattern as every other app in modules/apps/.
  flake.modules.nixos.wireless-audit = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      tcpdump
      aircrack-ng
      iw
      reaverwps    # reaver itself; its bundled wash is unreliable here, ignore it
      bully        # reaver's alternative; try this if reaver stalls or lacks a feature
    ];
  };
}
