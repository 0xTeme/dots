{
  flake.modules.homeManager.nixvim = {
    programs.nixvim = {
      plugins.gitsigns.enable = true;

      # <leader>g* rather than <leader>h*: <leader>h is already "focus left split", and a
      # longer mapping would make it wait for the next key.
      keymaps = [
        { mode = "n"; key = "]h"; action = "<cmd>Gitsigns next_hunk<CR>"; options.desc = "Next hunk"; }
        { mode = "n"; key = "[h"; action = "<cmd>Gitsigns prev_hunk<CR>"; options.desc = "Previous hunk"; }
        { mode = "n"; key = "<leader>gp"; action = "<cmd>Gitsigns preview_hunk<CR>"; options.desc = "Preview hunk"; }
        { mode = "n"; key = "<leader>gs"; action = "<cmd>Gitsigns stage_hunk<CR>"; options.desc = "Stage hunk"; }
        { mode = "n"; key = "<leader>gr"; action = "<cmd>Gitsigns reset_hunk<CR>"; options.desc = "Reset hunk"; }
        { mode = "n"; key = "<leader>gb"; action = "<cmd>Gitsigns blame_line<CR>"; options.desc = "Blame line"; }
      ];
    };
  };
}
