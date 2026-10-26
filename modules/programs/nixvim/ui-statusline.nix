{ lib, ... }:
{
  # Bottom bar and tab row, colored from the editor's highlight groups. Lualine builds its
  # own per-mode groups and needs colors as "#rrggbb" strings. Neovim returns colors as
  # numbers, so every value is converted at the point it goes into the lualine theme.
  # mkAfter runs this after the palette loads, and the ColorScheme autocommand keeps it
  # in step on every change.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.lualine.enable = true;

    extraConfigLuaPost = lib.mkAfter ''
      local function hl(name)
        return vim.api.nvim_get_hl(0, { name = name, link = false })
      end

      -- Neovim gives colors as numbers. Lualine needs "#rrggbb" strings.
      local function hex(n)
        if n == nil then return nil end
        return string.format("#%06x", n)
      end

      local function mode(color, bg, fg, cbg)
        return {
          a = { fg = hex(bg), bg = hex(color), gui = "bold" },
          b = { fg = hex(fg), bg = hex(cbg) },
          c = { fg = hex(fg), bg = hex(bg) },
          x = { fg = hex(hl("Comment").fg), bg = hex(bg) },
          y = { fg = hex(fg), bg = hex(cbg) },
          z = { fg = hex(bg), bg = hex(color), gui = "bold" },
        }
      end

      local function palette()
        local normal = hl("Normal")
        local bg = normal.bg
        local fg = normal.fg
        local cbg = hl("CursorLine").bg or bg
        local dim = { fg = hex(hl("Comment").fg), bg = hex(bg) }

        local function accent(name)
          return hl(name).fg or hl("Keyword").fg
        end

        return {
          normal = mode(accent("Keyword"), bg, fg, cbg),
          insert = mode(accent("String"), bg, fg, cbg),
          visual = mode(accent("Constant"), bg, fg, cbg),
          replace = mode(accent("DiagnosticError"), bg, fg, cbg),
          command = mode(accent("Type"), bg, fg, cbg),
          inactive = { a = dim, b = dim, c = dim, x = dim, y = dim, z = dim },
        }
      end

      local function apply()
        -- Tab row and bar background match Normal.
        local normal = hl("Normal")
        local comment = hl("Comment")
        local accent = hl("Keyword")
        vim.api.nvim_set_hl(0, "StatusLine", { fg = normal.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "StatusLineNC", { fg = comment.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "TabLine", { fg = comment.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "TabLineFill", { fg = comment.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "TabLineSel", { fg = accent.fg, bg = normal.bg, bold = true })

        -- Lualine's setup replaces the whole config, so the sections are repeated here.
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
