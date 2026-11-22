{
  # The on-screen keyboard as a user service, with its colours taken from Noctalia's palette.
  # It runs as its own unit, so a palette change restarts only the keyboard, and nothing kills it
  # when a helper finishes. Show, hide and refresh are plain systemctl operations, so the bar
  # button, the flip hook and the palette watcher all drive the same unit.
  flake.modules.homeManager.osk-theme = { pkgs, ... }:
    let
      systemctl = "${pkgs.systemd}/bin/systemctl";
      grep = "${pkgs.gnugrep}/bin/grep";

      # Runs wvkbd in the foreground, so the service tracks it. Colours come from the palette,
      # read at start. Roles follow the surface model: the background and key fill are surface
      # tones, the text is the foreground, special keys use the accent. Each role tries a few
      # names, so one missing name doesn't break the keyboard. -R 0 keeps the corners sharp.
      run = pkgs.writeShellScriptBin "niri-osk-run" ''
        src="$HOME/.config/gtk-4.0/noctalia.css"
        colour() {
          ${grep} -m1 "@define-color $1 " "$src" 2>/dev/null | ${grep} -oE '#[0-9a-fA-F]{6}' | head -n1 | tr -d '#'
        }
        pick() {
          local n c
          for n in "$@"; do
            c=$(colour "$n")
            if [ -n "$c" ]; then echo "$c"; return 0; fi
          done
          return 1
        }
        bg=$(pick window_bg_color view_bg_color);       bg=''${bg:-151310}
        keys=$(pick card_bg_color view_bg_color window_bg_color); keys=''${keys:-1d1b18}
        text=$(pick window_fg_color);                  text=''${text:-e8e1dc}
        acc=$(pick accent_color);                      acc=''${acc:-dfc299}
        accfg=$(pick accent_fg_color);                 accfg=''${accfg:-151310}

        exec ${pkgs.wvkbd}/bin/wvkbd-mobintl \
          --bg "$bg" --fg "$keys" --text "$text" \
          --fg-sp "$acc" --text-sp "$accfg" \
          --press "$acc" --press-sp "$acc" --swipe "$acc" \
          -R 0 --fn "Iosevka Nerd Font Mono 14" \
          -H 340 -L 300
      '';

      # The one command everything calls. It only drives the unit, so the keyboard keeps its state.
      osk = pkgs.writeShellScriptBin "niri-osk" ''
        case "''${1:-toggle}" in
          show) ${systemctl} --user start niri-osk.service ;;
          hide) ${systemctl} --user stop niri-osk.service ;;
          toggle)
            if ${systemctl} --user is-active --quiet niri-osk.service; then
              ${systemctl} --user stop niri-osk.service
            else
              ${systemctl} --user start niri-osk.service
            fi
            ;;
          refresh) ${systemctl} --user try-restart niri-osk.service ;;
          *)
            echo "usage: niri-osk show|hide|toggle|refresh" >&2
            exit 2
            ;;
        esac
      '';
    in
    {
      home.packages = [
        osk
        run
      ];

      systemd.user.services.niri-osk = {
        Unit.Description = "On-screen keyboard (wvkbd)";
        Service = {
          ExecStart = "${run}/bin/niri-osk-run";
          Restart = "no";
        };
      };

      # Watches Noctalia's palette. A change restarts the keyboard only if it's running, so nothing
      # starts while the laptop is in laptop mode.
      systemd.user.paths.niri-osk-theme = {
        Unit.Description = "Watch Noctalia's palette for the on-screen keyboard";
        Path.PathChanged = "%h/.config/gtk-4.0/noctalia.css";
        Install.WantedBy = [ "default.target" ];
      };

      systemd.user.services.niri-osk-theme = {
        Unit.Description = "Restart the on-screen keyboard with the new palette";
        Install.WantedBy = [ "default.target" ];
        Service = {
          Type = "oneshot";
          ExecStart = "${systemctl} --user try-restart niri-osk.service";
        };
      };
    };
}
