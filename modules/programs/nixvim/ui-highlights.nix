{
  # Bars take their colors from the editor, so they follow the palette. The bottom bar sits
  # on the editor background, and the active tab uses the Keyword color as its accent. This
  # runs on every colorscheme load, so palette reloads keep it.
  flake.modules.homeManager.nixvim.programs.nixvim.extraConfigLuaPost = ''
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
