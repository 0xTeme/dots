{
  flake.modules.homeManager.nixvim = {
    programs.nixvim.plugins = {
      lsp.servers.ts_ls = {
        enable = true;
        packageFallback = true;
      };

      conform-nvim.settings.formatters_by_ft = {
        javascript = [ "prettier" ];
        javascriptreact = [ "prettier" ];
        typescript = [ "prettier" ];
        typescriptreact = [ "prettier" ];
      };
    };
  };
}
