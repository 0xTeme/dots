{
  flake.modules.homeManager.nixvim = {
    # nixd is set up in nixvim.nix. nixfmt runs on demand with <leader>cf and is left
    # out of format-on-save so saving a module never rewrites the whole file.
    programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft.nix = [ "nixfmt" ];
  };
}
