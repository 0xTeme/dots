{
  flake.modules.homeManager.nixvim = {
    programs.nixvim.plugins = {
      # clangd needs a compile_commands.json in the project (CMake: set
      # CMAKE_EXPORT_COMPILE_COMMANDS=ON, Make: run it under `bear --`).
      lsp.servers.clangd = {
        enable = true;
        packageFallback = true;
      };

      conform-nvim.settings.formatters_by_ft = {
        c = [ "clang_format" ];
        cpp = [ "clang_format" ];
      };
    };
  };
}
