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
    ];
  };

  flake.modules.homeManager.niri = { lib, ... }: {
    # config.kdl is the entry point. It includes base.kdl, which in turn includes
    # Noctalia's generated noctalia.kdl.
    xdg.configFile."niri/config.kdl" = {
      source = ./config.kdl;
      force = true;
    };

    xdg.configFile."niri/base.kdl" = {
      source = ./base.kdl;
      force = true;
    };

    # toggles.kdl must exist, otherwise niri logs a warning on every config reload.
    home.activation.niriToggles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "$HOME/.config/niri/toggles.kdl" ]; then
        $DRY_RUN_CMD touch "$HOME/.config/niri/toggles.kdl"
      fi
    '';
  };
}
