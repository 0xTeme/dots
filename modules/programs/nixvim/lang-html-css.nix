{
  flake.modules.homeManager.nixvim = {
    programs.nixvim.plugins = {
      # html, cssls and jsonls all come from the same package (vscode-langservers-extracted).
      lsp.servers = {
        html = {
          enable = true;
          packageFallback = true;
        };

        cssls = {
          enable = true;
          packageFallback = true;
        };
      };

      conform-nvim.settings.formatters_by_ft = {
        html = [ "prettier" ];
        css = [ "prettier" ];
        scss = [ "prettier" ];
      };
    };
  };
}
