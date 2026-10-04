{
  flake.modules.homeManager.nixvim = { config, ... }: {
    programs.nixvim.plugins = {
      # No formatter on purpose: prettier would reflow tables and lists.
      lsp.servers.marksman = {
        enable = true;
        packageFallback = true;
      };

      # Inline code, links and emphasis inside Markdown need this second grammar.
      treesitter.grammarPackages =
        with config.programs.nixvim.plugins.treesitter.package.builtGrammars;
        [ markdown_inline ];
    };
  };
}
