{
  # Flip mode for the 2-in-1. niri raises the tablet-mode switch events, and niri-flip on or off
  # runs the on-screen keyboard and the auto-rotation together. Nothing runs during normal laptop
  # use. Auto-rotation reads the accelerometer's raw axes directly from sysfs, so it needs no
  # daemon, and it only calls niri when the orientation changes.
  flake.modules.nixos.tablet-mode = { pkgs, ... }:
    let
      setsid = "${pkgs.util-linux}/bin/setsid";
      pgrep = "${pkgs.procps}/bin/pgrep";
      pkill = "${pkgs.procps}/bin/pkill";
      kbd = "${pkgs.wvkbd}/bin/wvkbd-mobintl";
      niri = "${pkgs.niri}/bin/niri";

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

      # Reads the accelerometer's raw axes and rotates the screen to match gravity. The mapping
      # comes from measurements on this laptop: phone upright is +x (90), phone upside down is -x
      # (270), landscape upright is -y (normal), landscape upside down is +y (180). A flat laptop
      # has z dominant, so the screen is left where it is. A new orientation must hold for two
      # samples before it's applied, which stops flicker near the edges.
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
                ${niri} msg output "$out" transform "$cand" >/dev/null 2>&1 && cur=$cand
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
      environment.systemPackages = [
        pkgs.wvkbd
        osk
        rotate
        flip
      ];
    };
}
