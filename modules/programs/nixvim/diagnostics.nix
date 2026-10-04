{
  flake.modules.homeManager.nixvim = {
    programs.nixvim = {
      # Square borders for every floating window (hover, diagnostics, pickers).
      opts.winborder = "single";

      extraConfigLua = ''
        vim.diagnostic.config({
          severity_sort = true,
          update_in_insert = false,
          virtual_text = { spacing = 2, prefix = "■" },
          float = { source = true },
        })
      '';
    };
  };
}
