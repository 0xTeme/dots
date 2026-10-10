{
  flake.modules.nixos.niri = { pkgs, ... }: {
    programs.niri.enable = true;

    # Carried over from the old config: do not force NixOS's default PATH on the niri service.
    systemd.user.services.niri.enableDefaultPath = false;

    # niri has no runtime switch for input devices. This script rewrites toggles.kdl,
    # which config.kdl includes last, and niri live-reloads it. A non-empty file means
    # the touchscreen is off. It lives in the system profile so niri's spawn finds it,
    # the same way it finds foot and noctalia. The state survives reboots.
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "niri-toggle-touch" ''
        f="$HOME/.config/niri/toggles.kdl"
        if [ -s "$f" ]; then
          : > "$f"
          noctalia msg notification-show "Touchscreen enabled"
        else
          printf 'input {\n    touch {\n        off\n    }\n}\n' > "$f"
          noctalia msg notification-show "Touchscreen disabled"
        fi
      '')
      (pkgs.writeShellScriptBin "niri-toggle-look" ''
        arg="$1"
        if [ "$arg" = "gaps" ]; then
          f="$HOME/.config/niri/gaps.kdl"
          off_content='layout {\n    gaps 0\n}\n'
          title="Gaps"
        elif [ "$arg" = "blur" ]; then
          f="$HOME/.config/niri/blur.kdl"
          off_content='window-rule {\n    background-effect {\n        blur false\n    }\n}\n'
          title="Blur"
        else
          exit 1
        fi

        if [ -s "$f" ]; then
          : > "$f"
          noctalia msg notification-show "$title enabled"
        else
          printf "$off_content" > "$f"
          noctalia msg notification-show "$title disabled"
        fi
      '')
    ];
  };

  flake.modules.homeManager.niri = { lib, ... }: {
    # config.kdl is the entry point. It includes base.kdl, which in turn includes
    # Noctalia's generated noctalia.kdl.
    xdg.configFile."niri/base.kdl" = {
      source = ./base.kdl;
      force = true;
    };

    # toggles.kdl and cursor.kdl must exist, otherwise niri logs a warning on every config reload.
    # config.kdl is copied as a regular file rather than symlinked, because the Noctalia
    # cursor plugin touches (os.utime) it to force niri to reload the included cursor.kdl.
    home.activation.niriToggles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.config/niri
      $DRY_RUN_CMD rm -f $HOME/.config/niri/config.kdl
      $DRY_RUN_CMD cat ${./config.kdl} > $HOME/.config/niri/config.kdl

      if [ ! -e "$HOME/.config/niri/toggles.kdl" ]; then
        $DRY_RUN_CMD touch "$HOME/.config/niri/toggles.kdl"
      fi
      if [ ! -e "$HOME/.config/niri/cursor.kdl" ]; then
        $DRY_RUN_CMD touch "$HOME/.config/niri/cursor.kdl"
      fi
      if [ ! -e "$HOME/.config/niri/gaps.kdl" ]; then
        $DRY_RUN_CMD touch "$HOME/.config/niri/gaps.kdl"
      fi
      if [ ! -e "$HOME/.config/niri/blur.kdl" ]; then
        $DRY_RUN_CMD touch "$HOME/.config/niri/blur.kdl"
      fi
    '';
  };
}
