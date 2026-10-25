{
  # Makes running GTK apps reload after Noctalia rewrites its palette. GTK caches the
  # theme, icons and color scheme by name, so it only rereads them when the name changes.
  # Each value is switched to a neighbor name and back.
  #
  # The script waits until the palette files stop changing, so a burst of writes becomes
  # one reload instead of several queued ones. Only one reload runs at a time. The
  # libadwaita color scheme goes first, since Nautilus follows it.
  flake.modules.homeManager.gtk-reload = { pkgs, ... }:
    let
      reload = pkgs.writeShellScript "gtk-reload" ''
        set -u
        dconf=${pkgs.dconf}/bin/dconf
        sleep=${pkgs.coreutils}/bin/sleep
        stat=${pkgs.coreutils}/bin/stat
        date=${pkgs.coreutils}/bin/date
        flock=${pkgs.util-linux}/bin/flock
        seq=${pkgs.coreutils}/bin/seq

        # One reload at a time. A change that arrives mid-run is covered by the settle
        # wait below, or by the next run if it comes later.
        exec 9>"$XDG_RUNTIME_DIR/gtk-reload.lock"
        if ! $flock -n 9; then
          exit 0
        fi

        newest_palette() {
          newest=0
          for f in "$HOME/.config/gtk-3.0/noctalia.css" "$HOME/.config/gtk-4.0/noctalia.css"; do
            if [ -e "$f" ]; then
              m=$($stat -c %Y "$f")
              if [ "$m" -gt "$newest" ]; then newest=$m; fi
            fi
          done
          echo "$newest"
        }

        # Wait until the palette files have been unchanged for a second.
        for _ in $($seq 20); do
          newest=$(newest_palette)
          now=$($date +%s)
          if [ $((now - newest)) -ge 1 ]; then break; fi
          $sleep 0.3
        done

        # Noctalia's icon hook recolors Papirus after the palette files are written.
        $sleep 1

        bounce() {
          key=$1
          reset=$2
          cur=$($dconf read "$key")
          if [ -z "$cur" ]; then return 0; fi
          $dconf write "$key" "$reset"
          $sleep 0.1
          $dconf write "$key" "$cur"
        }

        bounce /org/gnome/desktop/interface/color-scheme "'default'"

        icons=$($dconf read /org/gnome/desktop/interface/icon-theme)
        case "$icons" in
          *Papirus*) bounce /org/gnome/desktop/interface/icon-theme "'Papirus'" ;;
        esac

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
