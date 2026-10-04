{
  flake.modules.homeManager.nixvim = { pkgs, ... }: {
    programs.nixvim = {
      plugins = {
        lsp.servers.bashls = {
          enable = true;
          packageFallback = true;
        };

        conform-nvim.settings.formatters_by_ft = {
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
        };
      };

      # bashls runs shellcheck when it is on PATH.
      extraPackages = [ pkgs.shellcheck ];
    };
  };
}
