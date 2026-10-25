{
  # GTK 3 theme for Noctalia. Noctalia's GTK 3 template writes libadwaita color names
  # (window_bg_color and friends), which adw-gtk3 uses. Adwaita-dark uses older names,
  # so the palette never reached GTK 3 widgets. Noctalia still owns gtk.css.
  flake.modules.homeManager.gtk-dark = { pkgs, ... }: {
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
