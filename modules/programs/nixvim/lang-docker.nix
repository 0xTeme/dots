{
  flake.modules.homeManager.nixvim = { config, ... }: {
    programs.nixvim.plugins = {
      lsp.servers.dockerls = {
        enable = true;
        packageFallback = true;
      };

      treesitter.grammarPackages =
        with config.programs.nixvim.plugins.treesitter.package.builtGrammars;
        [ dockerfile ];
    };
  };
}
