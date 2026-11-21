{
  # Flip mode for the 2-in-1. The laptop's tablet-mode switch is read by niri, which runs
  # niri-osk show on flip-in and niri-osk hide on flip-out, so nothing polls while the laptop
  # is used normally. wvkbd is the on-screen keyboard, a layer-shell overlay. The nixpkgs
  # package only ships the mobile layout, wvkbd-mobintl, which suits touch.
  # hardware.sensor.iio exposes the accelerometer for auto-rotation, added in a later step.
  flake.modules.nixos.tablet-mode = { pkgs, ... }:
    let
      osk = pkgs.writeShellScriptBin "niri-osk" ''
        # Absolute store paths, so niri's spawn environment can't change what runs.
        # setsid -f detaches wvkbd into its own session, so it survives the calling shell and
        # starts in the background without racing the check that follows it.
        kbd=${pkgs.wvkbd}/bin/wvkbd-mobintl
        pgrep=${pkgs.procps}/bin/pgrep
        pkill=${pkgs.procps}/bin/pkill
        setsid=${pkgs.util-linux}/bin/setsid

        running() { "$pgrep" -x wvkbd-mobintl >/dev/null; }
        start() { running || "$setsid" -f "$kbd" >/dev/null 2>&1; }
        stop() { "$pkill" -x wvkbd-mobintl 2>/dev/null || true; }

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
    in
    {
      hardware.sensor.iio.enable = true;

      environment.systemPackages = [
        pkgs.wvkbd
        osk
      ];
    };
}
