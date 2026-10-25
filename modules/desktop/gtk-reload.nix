{
  # GTK reads its CSS only when the theme name changes. Noctalia rewrites noctalia.css
  # on every palette change, but a wallpaper change within the same light or dark mode
  # leaves the theme name alone, so running GTK apps keep the old colors. This resets the
  # name and sets it back, which makes running GTK apps reload. Omarchy does the same.
  flake.modules.homeManager.gtk-reload = { pkgs, ... }:
    let
      reload = pkgs.writeShellScript "gtk-reload" ''
        set -eu
        dconf=${pkgs.dconf}/bin/dconf
        current=$($dconf read /org/gnome/desktop/interface/gtk-theme)
        [ -n "$current" ] || exit 0
        $dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
        sleep 0.3
        $dconf write /org/gnome/desktop/interface/gtk-theme "$current"
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
