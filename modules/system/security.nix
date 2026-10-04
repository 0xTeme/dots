{
  flake.modules.nixos.security = {
    # Polkit authority only. The prompt UI comes from Noctalia's own agent setting.
    security.polkit.enable = true;

    networking.firewall.enable = true;
  };
}
