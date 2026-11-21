{
  # Flip mode for the 2-in-1. The laptop's tablet-mode switch is read by niri, which runs
  # niri-osk show on flip-in and niri-osk hide on flip-out, so nothing polls while the laptop
  # is used normally. wvkbd is the on-screen keyboard, a layer-shell overlay. The nixpkgs
  # package only ships the mobile layout, wvkbd-mobintl, which is the one that suits touch.
  # hardware.sensor.iio exposes the accelerometer for auto-rotation, added in a later step.
  flake.modules.nixos.tablet-mode = { pkgs, ... }:
    let
      osk = pkgs.writeShellScriptBin "niri-osk" ''
        # wvkbd runs as a layer-shell overlay, so show and hide are process-level operations.
        # The process name is wvkbd-mobintl, which is short enough for pkill -x to match.
        case "''${1:-toggle}" in
          show)
            pgrep -x wvkbd-mobintl >/dev/null || nohup wvkbd-mobintl >/dev/null 2>&1 &
            ;;
          hide)
            pkill -x wvkbd-mobintl 2>/dev/null || true
            ;;
          toggle)
            if pgrep -x wvkbd-mobintl >/dev/null; then
              pkill -x wvkbd-mobintl
            else
              nohup wvkbd-mobintl >/dev/null 2>&1 &
            fi
            ;;
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
