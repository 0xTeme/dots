{
  # Makes running GTK apps reload after Noctalia rewrites its palette or recolors icons.
  # GTK caches theme, icon and color-scheme values by name, so each one is switched and
  # restored in one step. The script watches the palette files and Papirus folders, and
  # reloads as soon as they stop changing, instead of waiting a fixed time.
  flake.modules.homeManager.gtk-reload = { pkgs, ... }:
    let
      reload = pkgs.writeShellScript "gtk-reload" ''
        set -u
        dconf=${pkgs.dconf}/bin/dconf
        sleep=${pkgs.coreutils}/bin/sleep
        stat=${pkgs.coreutils}/bin/stat
        seq=${pkgs.coreutils}/bin/seq
        flock=${pkgs.util-linux}/bin/flock

        # One reload at a time.
        exec 9>"$XDG_RUNTIME_DIR/gtk-reload.lock"
        $flock -n 9 || exit 0

        # Modification times of the palette files and the recolored icon folders.
        snapshot() {
          $stat -c '%Y' "$HOME/.config/gtk-3.0/noctalia.css" \
            "$HOME/.config/gtk-4.0/noctalia.css" \
            "$HOME"/.local/share/icons/Papirus* 2>/dev/null | tr '\n' ' '
        }

        # Short grace period for Noctalia's hooks to start, then wait until the snapshot
        # has been unchanged for half a second. Capped at about ten seconds.
        $sleep 0.2
        prev=""
        stable=0
        for _ in $($seq 40); do
          cur=$(snapshot)
          if [ "$cur" = "$prev" ]; then
            stable=$((stable + 1))
            if [ "$stable" -ge 2 ]; then break; fi
          else
            stable=0
          fi
          prev=$cur
          $sleep 0.25
        done

        cs=$($dconf read /org/gnome/desktop/interface/color-scheme)
        gt=$($dconf read /org/gnome/desktop/interface/gtk-theme)
        ic=$($dconf read /org/gnome/desktop/interface/icon-theme)

        # Switch all three to a neighbor value at once, then restore them together.
        $dconf write /org/gnome/desktop/interface/color-scheme "'default'"
        $dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
        case "$ic" in *Papirus*) $dconf write /org/gnome/desktop/interface/icon-theme "'Papirus'" ;; esac

        $sleep 0.1

        if [ -n "$cs" ]; then $dconf write /org/gnome/desktop/interface/color-scheme "$cs"; fi
        if [ -n "$gt" ]; then $dconf write /org/gnome/desktop/interface/gtk-theme "$gt"; fi
        case "$ic" in *Papirus*) $dconf write /org/gnome/desktop/interface/icon-theme "$ic" ;; esac
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
