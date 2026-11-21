{
  # Flip mode for the 2-in-1. niri raises the tablet-mode switch events, and niri-flip on or off
  # runs the keyboard and the rotation together. Nothing runs during normal laptop use: the
  # accelerometer is claimed only while the laptop is folded into a tablet.
  flake.modules.nixos.tablet-mode = { pkgs, ... }:
    let
      gdbus = "${pkgs.glib}/bin/gdbus";
      niri = "${pkgs.niri}/bin/niri";
      setsid = "${pkgs.util-linux}/bin/setsid";
      pgrep = "${pkgs.procps}/bin/pgrep";
      pkill = "${pkgs.procps}/bin/pkill";
      kbd = "${pkgs.wvkbd}/bin/wvkbd-mobintl";

      osk = pkgs.writeShellScriptBin "niri-osk" ''
        # Absolute store paths, so niri's spawn environment can't change what runs.
        # setsid -f detaches wvkbd into its own session, so it survives the calling shell.
        running() { ${pgrep} -x wvkbd-mobintl >/dev/null; }
        start() { running || ${setsid} -f ${kbd} >/dev/null 2>&1; }
        stop() { ${pkill} -x wvkbd-mobintl 2>/dev/null || true; }

        case "''${1:-toggle}" in
          show) start ;;
          hide) stop ;;
          toggle) if running; then stop; else start; fi ;;
          *)
            echo "usage: niri-osk show|hide|toggle" >&2
            exit 2
            ;;
        esac
      '';

      # Follows the accelerometer and sets the screen's transform to match. It runs in its own
      # session so stop can signal the whole group, including the gdbus monitor child.
      rotate = pkgs.writeShellScriptBin "niri-rotate" ''
        dest=net.hadess.SensorProxy
        path=/net/hadess/SensorProxy
        out=eDP-1
        pidfile="''${XDG_RUNTIME_DIR:-/tmp}/niri-rotate.pid"

        # Maps the sensor's orientation to niri's output transform. Checked with a manual
        # transform test. If the screen turns the wrong way on a flip, swap 90 and 270.
        transform_for() {
          case "$1" in
            normal) echo normal ;;
            bottom-up) echo 180 ;;
            left-up) echo 90 ;;
            right-up) echo 270 ;;
            *) return 1 ;;
          esac
        }

        run() {
          echo "$$" > "$pidfile"
          trap 'exit 0' TERM INT
          trap '${gdbus} call --system --dest $dest --object-path $path --method $dest.ReleaseAccelerometer >/dev/null 2>&1; rm -f "$pidfile"' EXIT

          ${gdbus} call --system --dest "$dest" --object-path "$path" --method "$dest.ClaimAccelerometer" >/dev/null || exit 1

          ${gdbus} monitor --system --dest "$dest" --object-path "$path" | while read -r line; do
            case "$line" in
              *AccelerometerOrientation*) ;;
              *) continue ;;
            esac
            o=$(printf '%s\n' "$line" | grep -o "<'[a-z-]*'>" | head -n1 | tr -d "<>'")
            t=$(transform_for "$o") || continue
            ${niri} msg output "$out" transform "$t" >/dev/null 2>&1
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

      flip = pkgs.writeShellScriptBin "niri-flip" ''
        case "''${1:-}" in
          on) niri-osk show; niri-rotate start ;;
          off) niri-osk hide; niri-rotate stop ;;
          *)
            echo "usage: niri-flip on|off" >&2
            exit 2
            ;;
        esac
      '';
    in
    {
      # iio-sensor-proxy exposes the accelerometer over D-Bus. It starts on demand when claimed.
      hardware.sensor.iio.enable = true;

      environment.systemPackages = [
        pkgs.wvkbd
        pkgs.glib
        osk
        rotate
        flip
      ];
    };
}
