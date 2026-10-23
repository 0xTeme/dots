{
  # One file picker for the system: file-open and save dialogs open Yazi in a Foot
  # window. xdg.portal routes only the FileChooser interface. Screencast, notifications
  # and secrets keep their backends.
  flake.modules.nixos.file-picker = { pkgs, ... }: {
    xdg.portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
      config.niri = {
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
    };
  };

  # The backend reads its config from the user config directory, which it searches
  # first. TERMCMD must be set here. When it's unset, the Yazi wrapper falls back to
  # kitty, which isn't installed, and every dialog fails with exit code -127.
  # The app-id lets niri float only this window.
  flake.modules.homeManager.file-picker = {
    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=yazi-wrapper.sh
      env=TERMCMD='foot --app-id=file-picker'
      open_mode=suggested
      save_mode=last
      default_dir=$HOME
      create_help_file=0
    '';
  };
}
