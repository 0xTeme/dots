{
  # Run through the Firefox module with its package swapped, not programs.librewolf
  # directly: there's an open Home Manager bug where LibreWolf's own module doesn't
  # actually apply policies/extensions at runtime (nix-community/home-manager#7948).
  # The Firefox module correctly targets whatever package you give it.
  flake.modules.homeManager.librewolf = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;

      policies.ExtensionSettings = {
        # Force-dark on every site, not just ones with a native toggle. Custom CSS
        # (square corners etc.) does NOT go here, Dynamic mode and custom CSS are
        # mutually exclusive within Dark Reader itself, see Stylus below instead.
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };

        # Stylus: a second, separate extension purely for always-on global CSS
        # like square corners. Runs independently of Dark Reader's mode.
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/5044316/styl_us-2.4.14.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
