{
  # GTK3 apps only switch to dark when the active theme has a dark variant. Naming
  # Adwaita-dark sets that theme; the preference flags reinforce it. Noctalia supplies
  # the colors through gtk.css, which is still Noctalia-owned and not touched here.
  flake.modules.homeManager.gtk-dark = { pkgs, ... }: {
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
