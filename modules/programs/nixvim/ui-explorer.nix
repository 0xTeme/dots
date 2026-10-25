{
  # File explorer drawn like the `tree` command: plain connectors, no folder arrows.
  # The buffer isn't editable, so typing in it shows E21. Move focus to the editor with
  # Ctrl+w l, then edit.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      settings.renderer = {
        indent_width = 3;
        icons = {
          show.folder_arrow = false;
          padding = " ";
        };
        indent_markers = {
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
    };

    keymaps = [
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<CR>"; options.desc = "Toggle file explorer"; }
    ];
  };
}
