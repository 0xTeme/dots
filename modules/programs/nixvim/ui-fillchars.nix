{ lib, ... }:
{
  # Hides the ~ markers that show unused space below the last line. A blank character keeps
  # the same layout without drawing anything. This is global, so the file tree is covered too.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    extraConfigLuaPost = lib.mkAfter ''
      vim.opt.fillchars:append({ eob = " " })
    '';
  };
}
