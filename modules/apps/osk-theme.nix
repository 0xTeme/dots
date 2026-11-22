{
  # Refreshes the on-screen keyboard when Noctalia's palette changes. The keyboard reads the palette
  # only when it starts, so a change while it's open would otherwise wait for the next flip. The
  # watcher runs only on a palette write, and niri-osk refresh restarts the keyboard only if it's
  # showing, so there's no cost while the palette is stable.
  flake.modules.homeManager.osk-theme = {
    systemd.user.paths.niri-osk-theme = {
      Unit.Description = "Watch Noctalia's palette for the on-screen keyboard";
      Path.PathChanged = "%h/.config/gtk-4.0/noctalia.css";
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.niri-osk-theme = {
      Unit.Description = "Refresh the on-screen keyboard with Noctalia's palette";
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c 'sleep 1; /run/current-system/sw/bin/niri-osk refresh'";
      };
    };
  };
}
