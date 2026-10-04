{
  flake.modules.homeManager.nixvim = {
    programs.nixvim.plugins = {
      # pyright for types, ruff for linting. packageFallback lets a project's own
      # devshell version override these.
      lsp.servers = {
        pyright = {
          enable = true;
          packageFallback = true;
        };

        ruff = {
          enable = true;
          packageFallback = true;
        };
      };

      conform-nvim.settings.formatters_by_ft.python = [ "ruff_organize_imports" "ruff_format" ];
    };
  };
}
