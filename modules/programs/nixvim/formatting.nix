{
  flake.modules.homeManager.nixvim = {
    programs.nixvim = {
      plugins.conform-nvim = {
        enable = true;

        # Installs every formatter named in formatters_by_ft.
        autoInstall.enable = true;

        # Each language file adds its own formatters_by_ft entries.
        settings.format_on_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.bo[bufnr].filetype == "nix" then
              return
            end
            return { timeout_ms = 500, lsp_format = "fallback" }
          end
        '';
      };

      keymaps = [
        {
          mode = [ "n" "v" ];
          key = "<leader>cf";
          action.__raw = "function() require('conform').format({ lsp_format = 'fallback' }) end";
          options.desc = "Format buffer";
        }
      ];
    };
  };
}
