{ lib, ... }:
{
  # Bottom bar and tab row, colored from the editor's own highlight groups. Lualine
  # builds its own per-mode groups, so its theme is set here rather than left on "auto".
  # mkAfter runs this after the palette is loaded in nixvim.nix, so the colors come from
  # the active palette. The ColorScheme autocommand keeps them in step on every change.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.lualine.enable = true;

    extraConfigLuaPost = lib.mkAfter ''
      local function hl(name)
        return vim.api.nvim_get_hl(0, { name = name, link = false })
      end

      local function palette()
        local normal = hl("Normal")
        local comment = hl("Comment")
        local accent = hl("Keyword")
        local cline = hl("CursorLine")
        local bg = normal.bg
        local cbg = cline.bg or bg

        local function pick(name)
          return hl(name).fg or accent.fg
        end

        local function mode(color)
          return {
            a = { fg = bg, bg = color, bold = true },
            b = { fg = normal.fg, bg = cbg },
            c = { fg = normal.fg, bg = bg },
            x = { fg = comment.fg, bg = bg },
            y = { fg = normal.fg, bg = cbg },
            z = { fg = bg, bg = color, bold = true },
          }
        end

        local dim = { fg = comment.fg, bg = bg }
        return {
          normal = mode(accent.fg),
          insert = mode(pick("String")),
          visual = mode(pick("Constant")),
          replace = mode(pick("DiagnosticError")),
          command = mode(pick("Type")),
          inactive = { a = dim, b = dim, c = dim, x = dim, y = dim, z = dim },
        }
      end

      local function apply()
        -- Editor-bar highlights: the tab row and the bar background match Normal.
        local normal = hl("Normal")
        local comment = hl("Comment")
        local accent = hl("Keyword")
        local bg = normal.bg
        vim.api.nvim_set_hl(0, "StatusLine", { fg = normal.fg, bg = bg })
        vim.api.nvim_set_hl(0, "StatusLineNC", { fg = comment.fg, bg = bg })
        vim.api.nvim_set_hl(0, "TabLine", { fg = comment.fg, bg = bg })
        vim.api.nvim_set_hl(0, "TabLineFill", { fg = comment.fg, bg = bg })
        vim.api.nvim_set_hl(0, "TabLineSel", { fg = accent.fg, bg = bg, bold = true })

        -- Lualine: full setup again, now with the palette theme. Sections are repeated
        -- here because lualine.setup replaces the whole config.
        local ok, lualine = pcall(require, "lualine")
        if not ok then return end
        lualine.setup({
          options = {
            theme = palette(),
            globalstatus = true,
            component_separators = { left = "│", right = "│" },
            section_separators = { left = "", right = "" },
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff" },
            lualine_c = { "filename" },
            lualine_x = { "diagnostics", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
        })
      end

      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
      apply()
    '';
  };
}
