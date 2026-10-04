{
  flake.modules.homeManager.nixvim = {
    programs.nixvim = {
      plugins.fzf-lua = {
        enable = true;

        # Square window border, matching the rest of the desktop.
        settings.winopts.border = "single";
      };

      keymaps = [
        { mode = "n"; key = "<leader>ff"; action = "<cmd>FzfLua files<CR>"; options.desc = "Find files"; }
        { mode = "n"; key = "<leader>fg"; action = "<cmd>FzfLua live_grep<CR>"; options.desc = "Grep"; }
        { mode = "n"; key = "<leader>fb"; action = "<cmd>FzfLua buffers<CR>"; options.desc = "Buffers"; }
        { mode = "n"; key = "<leader>fr"; action = "<cmd>FzfLua oldfiles<CR>"; options.desc = "Recent files"; }
        { mode = "n"; key = "<leader>fh"; action = "<cmd>FzfLua helptags<CR>"; options.desc = "Help"; }
        { mode = "n"; key = "<leader>fd"; action = "<cmd>FzfLua diagnostics_document<CR>"; options.desc = "Diagnostics"; }
        { mode = "n"; key = "<leader>fs"; action = "<cmd>FzfLua lsp_document_symbols<CR>"; options.desc = "Symbols"; }
      ];
    };
  };
}
