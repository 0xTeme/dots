{
  # Tabs, showing every open file across the top, standard multi-file editing.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.bufferline.enable = true;

    keymaps = [
      { mode = "n"; key = "<Tab>"; action = "<cmd>BufferLineCycleNext<CR>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<S-Tab>"; action = "<cmd>BufferLineCyclePrev<CR>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>"; options.desc = "Close buffer"; }
    ];
  };
}
