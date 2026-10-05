{
  flake.modules.homeManager.yazi = {
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;

      # Flavor selection is config, so Nix owns it. Noctalia's apply.sh only rewrites
      # theme.toml when the content differs, so with exactly this it does nothing.
      theme.flavor = {
        dark = "noctalia";
        light = "noctalia";
      };

      settings = {
        opener = {
          edit = [
            { run = "nvim %s"; block = true; desc = "Neovim"; for = "unix"; }
          ];
          read = [
            { run = "glow -p %s1"; block = true; desc = "Read with glow"; for = "unix"; }
          ];
          imv = [
            { run = "imv -n %s1 %d1"; orphan = true; desc = "imv, whole folder"; for = "unix"; }
          ];
        };

        # Prepended rules win over the preset. Everything else (PDF, audio, video,
        # archives) keeps the preset, which goes through xdg-open and mimeapps.list.
        open.prepend_rules = [
          { url = "*.md"; use = [ "read" "edit" ]; }
          { url = "*.markdown"; use = [ "read" "edit" ]; }
          { mime = "image/*"; use = [ "imv" "open" ]; }
        ];
      };

      keymap.mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Mount, unmount, eject and jump to drives";
        }
      ];

      initLua = ''
        require("full-border"):setup({ type = ui.Border.PLAIN })
      '';
    };
  };
}
