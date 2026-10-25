{
  # GTK caches its theme and icons by name, and Noctalia reuses the same names. When the
  # palette or the recolored icons change, the names stay the same, so running apps keep
  # the old look. This resets each setting and sets it back, which makes running apps
  # reload. libadwaita apps (Nautilus) also need the color-scheme bounce, since they
  # ignore the legacy GTK theme name. Omarchy does the same kind of bounce.
  flake.modules.homeManager.gtk-reload = { pkgs, ... }:
    let
      reload = pkgs.writeShellScript "gtk-reload" ''
        set -eu
        dconf=${pkgs.dconf}/bin/dconf

        # Noctalia's icon hook recolors the Papirus folders after the palette files are
        # written. Give it time to finish before the bounce.
        sleep 2

        bounce() {
          key=$1
          reset=$2
          cur=$($dconf read "$key")
          [ -n "$cur" ] || return 0
          $dconf write "$key" "$reset"
          sleep 0.3
          $dconf write "$key" "$cur"
        }

        bounce /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
        bounce /org/gnome/desktop/interface/icon-theme "'Adwaita'"
        bounce /org/gnome/desktop/interface/color-scheme "'default'"
      '';
    in
    {
      systemd.user.paths.gtk-reload = {
        Unit.Description = "Watch Noctalia's GTK palette files";
        Path.PathChanged = [
          "%h/.config/gtk-3.0/noctalia.css"
          "%h/.config/gtk-4.0/noctalia.css"
        ];
        Install.WantedBy = [ "default.target" ];
      };

      systemd.user.services.gtk-reload = {
        Unit.Description = "Make running GTK apps reload Noctalia's palette and icons";
        Service = {
          Type = "oneshot";
          ExecStart = "${reload}";
        };
      };
    };
}
