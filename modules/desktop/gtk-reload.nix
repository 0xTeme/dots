{
  # Makes running GTK apps reload after Noctalia rewrites its palette. GTK caches the
  # theme, icons and color scheme by name, so it only rereads them when the name changes.
  # Each value is switched to a neighbor name and back. The icons switch between Papirus
  # names, both of which Noctalia's hook recolors, so the stock Adwaita icons never show.
  flake.modules.homeManager.gtk-reload = { pkgs, ... }:
    let
      reload = pkgs.writeShellScript "gtk-reload" ''
        set -eu
        dconf=${pkgs.dconf}/bin/dconf

        # Let Noctalia's hooks finish writing the palette and recoloring the icons.
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

        icons=$($dconf read /org/gnome/desktop/interface/icon-theme)
        case "$icons" in
          *Papirus*) bounce /org/gnome/desktop/interface/icon-theme "'Papirus'" ;;
        esac

        bounce /org/gnome/desktop/interface/color-scheme "'default'"
        bounce /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
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
