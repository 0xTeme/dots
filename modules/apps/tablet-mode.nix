{
  # Flip mode for the 2-in-1. niri raises the tablet-mode switch events, and niri-flip on or off
  # runs the on-screen keyboard, the auto-rotation, the touchscreen and the gesture service together.
  # Nothing runs during normal laptop use. Touch is switched off at login, and this module turns it
  # on when folded, by clearing the same toggles file niri-toggle-touch uses.
  flake.modules.nixos.tablet-mode = { pkgs, ... }:
    let
      setsid = "${pkgs.util-linux}/bin/setsid";
      pgrep = "${pkgs.procps}/bin/pgrep";
      pkill = "${pkgs.procps}/bin/pkill";
      grep = "${pkgs.gnugrep}/bin/grep";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      kbd = "${pkgs.wvkbd}/bin/wvkbd-mobintl";
      niri = "${pkgs.niri}/bin/niri";

      # Colours come from Noctalia's palette, read when the keyboard starts and again on a palette
      # change (see niri-osk refresh). Roles follow the surface model: the background and the key
      # fill are surface tones, the key text is the foreground, and special keys use the accent.
      # Each role tries a few names, so one missing name doesn't break the keyboard. -R 0 keeps the
      # corners sharp. -H and -L are the phone-hold and landscape heights, in pixels.
      osk = pkgs.writeShellScriptBin "niri-osk" ''
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

        running() { ${pgrep} -x wvkbd-mobintl >/dev/null; }

        start() {
          running && return 0
          ${setsid} -f ${kbd} \
            --bg "$bg" --fg "$keys" --text "$text" \
            --fg-sp "$acc" --text-sp "$accfg" \
            --press "$acc" --press-sp "$acc" --swipe "$acc" \
            -R 0 --fn "Iosevka Nerd Font Mono 14" \
            -H 340 -L 300 >/dev/null 2>&1
        }
        stop() { ${pkill} -x wvkbd-mobintl 2>/dev/null || true; }

        case "''${1:-toggle}" in
          show) start ;;
          hide) stop ;;
          toggle) if running; then stop; else start; fi ;;
          refresh) if running; then stop; sleep 0.3; start; fi ;;
          *)
            echo "usage: niri-osk show|hide|toggle|refresh" >&2
            exit 2
            ;;
        esac
      '';

      # Reads the accelerometer's raw axes and rotates the screen to match gravity. The mapping
      # comes from measurements on this laptop: phone upright is +x (90), phone upside down is -x
      # (270), landscape upright is -y (normal), landscape upside down is +y (180). A flat laptop
      # has z dominant, so the screen is left where it is. A new orientation must hold for two
      # samples before it's applied, which stops flicker near the edges. After each change, every
      # gesture instance is stopped and the one for the new orientation is started, so only one
      # instance ever reads the touch device.
      rotate = pkgs.writeShellScriptBin "niri-rotate" ''
        out=eDP-1
        pidfile="''${XDG_RUNTIME_DIR:-/tmp}/niri-rotate.pid"

        find_accel() {
          local d n
          for d in /sys/bus/iio/devices/iio:device*; do
            read -r n < "$d/name" 2>/dev/null || continue
            if [ "$n" = accel_3d ]; then echo "$d"; return 0; fi
          done
          return 1
        }

        transform_for() {
          local x=$1 y=$2 z=$3 ax ay az
          ax=$x; ay=$y; az=$z
          (( ax < 0 )) && ax=$(( -ax ))
          (( ay < 0 )) && ay=$(( -ay ))
          (( az < 0 )) && az=$(( -az ))
          if (( ax > ay && ax > az )); then
            if (( x > 0 )); then echo 90; else echo 270; fi
          elif (( ay > az )); then
            if (( y < 0 )); then echo normal; else echo 180; fi
          fi
        }

        # The lisgd -o value for each screen transform: 90 degrees is one step. If a swipe goes the
        # wrong way on a rotated screen, swap the 1 and the 3 here.
        orient_for() {
          case "$1" in
            normal) echo 0 ;;
            90) echo 1 ;;
            180) echo 2 ;;
            270) echo 3 ;;
          esac
        }

        switch_gestures() {
          ${systemctl} --user stop 'lisgd@*.service' >/dev/null 2>&1 || true
          ${systemctl} --user start "lisgd@$1.service" >/dev/null 2>&1 || true
        }

        run() {
          echo "$$" > "$pidfile"
          trap 'exit 0' TERM INT
          trap 'rm -f "$pidfile"; ${niri} msg output "$out" transform normal >/dev/null 2>&1' EXIT

          dev=$(find_accel) || exit 1
          cur=""; pend=""; n=0
          while :; do
            read -r x < "$dev/in_accel_x_raw"
            read -r y < "$dev/in_accel_y_raw"
            read -r z < "$dev/in_accel_z_raw"
            cand=$(transform_for "$x" "$y" "$z")
            if [ -n "$cand" ] && [ "$cand" != "$cur" ]; then
              if [ "$cand" = "$pend" ]; then n=$((n + 1)); else pend=$cand; n=1; fi
              if [ "$n" -ge 2 ]; then
                if ${niri} msg output "$out" transform "$cand" >/dev/null 2>&1; then
                  cur=$cand
                  switch_gestures "$(orient_for "$cand")"
                fi
                pend=""; n=0
              fi
            fi
            sleep 0.5
          done
        }

        case "''${1:-}" in
          run) run ;;
          start)
            if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then exit 0; fi
            ${setsid} -f "$0" run
            ;;
          stop)
            if [ -f "$pidfile" ]; then
              pid=$(cat "$pidfile")
              kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
            fi
            ${niri} msg output "$out" transform normal >/dev/null 2>&1 || true
            ;;
          *)
            echo "usage: niri-rotate start|stop" >&2
            exit 2
            ;;
        esac
      '';

      # The touch-off override is a file niri includes. An empty file means touch is on, which is
      # the same state niri-toggle-touch produces. Writing the override back turns touch off again.
      flip = pkgs.writeShellScriptBin "niri-flip" ''
        toggles="$HOME/.config/niri/toggles.kdl"
        case "''${1:-}" in
          on)
            : > "$toggles"
            niri-osk show
            ${systemctl} --user stop 'lisgd@*.service' >/dev/null 2>&1 || true
            ${systemctl} --user start "lisgd@0.service" >/dev/null 2>&1 || true
            niri-rotate start
            ;;
          off)
            ${systemctl} --user stop 'lisgd@*.service' >/dev/null 2>&1 || true
            niri-rotate stop
            niri-osk hide
            printf 'input {\n    touch {\n        off\n    }\n}\n' > "$toggles"
            ;;
          *)
            echo "usage: niri-flip on|off" >&2
            exit 2
            ;;
        esac
      '';
    in
    {
      environment.systemPackages = [
        pkgs.wvkbd
        osk
        rotate
        flip
      ];
    };
}
