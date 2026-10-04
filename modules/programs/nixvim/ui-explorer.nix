{
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.nvim-tree.enable = true;

    keymaps = [
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<CR>"; options.desc = "Toggle file explorer"; }
    ];
  };
}
