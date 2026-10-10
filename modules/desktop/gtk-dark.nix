{
  # GTK3 apps check two places for dark mode. Noctalia writes the colors (gtk.css,
  # noctalia.css) but doesn't set either preference, so we set both here.
  flake.modules.homeManager.gtk-dark = {
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    xdg.configFile."gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
    '';
  };
}
