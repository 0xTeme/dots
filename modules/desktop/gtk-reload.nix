{
  # Makes running GTK apps reload after Noctalia rewrites its palette. GTK caches the
  # theme and color scheme by name, so it only rereads them when the value changes.
  # Each value is reset and restored, which triggers that reload. The icon theme is
  # deliberately not bounced: resetting it to Adwaita is visible as a flicker, and
  # Noctalia's Papirus hook recolors the folders in place, so icons may need a relaunch.
  flake.modules.homeManager.gtk-reload = { pkgs, ... }:
    let
      reload = pkgs.writeShellScript "gtk-reload" ''
        set -eu
        dconf=${pkgs.dconf}/bin/dconf

        # Let Noctalia's hooks finish writing the palette before reloading.
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
        Unit.Description = "Make running GTK apps reload Noctalia's palette";
        Service = {
          Type = "oneshot";
          ExecStart = "${reload}";
        };
      };
    };
}
