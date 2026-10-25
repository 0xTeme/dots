{
  # File explorer with tree connectors drawn like the `tree` command. The explorer
  # buffer isn't editable, so typing in it shows E21. Move focus to the editor with
  # Ctrl+w l, then edit.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      settings.renderer.indent_markers = {
        enable = true;
        inline_arrows = false;
        icons = {
          corner = "└";
          edge = "│";
          item = "├";
          bottom = "─";
          none = " ";
        };
      };
    };

    keymaps = [
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<CR>"; options.desc = "Toggle file explorer"; }
    ];
  };
}
