{
  flake.modules.homeManager.nixvim = {
    programs.nixvim.plugins = {
      # yamlls also covers docker-compose files, which are plain YAML.
      lsp.servers = {
        jsonls = {
          enable = true;
          packageFallback = true;
        };

        yamlls = {
          enable = true;
          packageFallback = true;
        };
      };

      conform-nvim.settings.formatters_by_ft = {
        json = [ "prettier" ];
        jsonc = [ "prettier" ];
        yaml = [ "prettier" ];
      };
    };
  };
}
