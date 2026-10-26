{ lib, ... }:
{
  # Bars take their colors from the editor. mkAfter puts this after the palette setup
  # in nixvim.nix, so Normal already has the palette's background when it's read. The
  # ColorScheme autocommand keeps it correct on every palette change.
  flake.modules.homeManager.nixvim.programs.nixvim.extraConfigLuaPost = lib.mkAfter ''
    local function apply()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
      local accent = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })
      local bg = normal.bg

      vim.api.nvim_set_hl(0, "StatusLine", { fg = normal.fg, bg = bg })
      vim.api.nvim_set_hl(0, "StatusLineNC", { fg = comment.fg, bg = bg })
      vim.api.nvim_set_hl(0, "TabLine", { fg = comment.fg, bg = bg })
      vim.api.nvim_set_hl(0, "TabLineFill", { fg = comment.fg, bg = bg })
      vim.api.nvim_set_hl(0, "TabLineSel", { fg = accent.fg, bg = bg, bold = true })

      local ok, lualine = pcall(require, "lualine")
      if ok then lualine.refresh() end
    end

    vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
    apply()
  '';
}
