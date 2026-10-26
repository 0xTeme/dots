{ lib, ... }:
{
  # Bottom bar and tab row, colored from the palette's real highlight groups, the same way
  # Omarchy and LazyVim theme lualine: each mode's badge uses its role's exact color, with
  # the editor background as the text color. Lualine needs "#rrggbb" strings, so Neovim's
  # numeric colors are converted at the point of use. The palette reload rewrites
  # matugen.lua without firing ColorScheme, so a file watcher on that file runs the same
  # update. mkAfter runs this after the palette loads in nixvim.nix.
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

      local function palette()
        local normal = hl("Normal")
        local bg = normal.bg
        local fg = normal.fg
        local cbg = hl("CursorLine").bg or bg
        local dim = { fg = hex(hl("Comment").fg), bg = hex(bg) }

        -- A mode badge: the role's exact color, with the editor background as the text.
        local function badge(role)
          local c = hl(role).fg or hl("Keyword").fg
          return {
            a = { fg = hex(bg), bg = hex(c), gui = "bold" },
            b = { fg = hex(fg), bg = hex(cbg) },
            c = { fg = hex(fg), bg = hex(bg) },
            x = { fg = hex(hl("Comment").fg), bg = hex(bg) },
            y = { fg = hex(fg), bg = hex(cbg) },
            z = { fg = hex(bg), bg = hex(c), gui = "bold" },
          }
        end

        return {
          normal = badge("Keyword"),
          insert = badge("String"),
          visual = badge("Constant"),
          replace = badge("DiagnosticError"),
          command = badge("Type"),
          inactive = { a = dim, b = dim, c = dim, x = dim, y = dim, z = dim },
        }
      end

      local function apply()
        local normal = hl("Normal")
        local comment = hl("Comment")
        local accent_hl = hl("Keyword")

        -- Tab row and bufferline sit on the editor background.
        vim.api.nvim_set_hl(0, "StatusLine", { fg = normal.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "StatusLineNC", { fg = comment.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "TabLine", { fg = comment.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "TabLineFill", { fg = comment.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "TabLineSel", { fg = accent_hl.fg, bg = normal.bg, bold = true })
        vim.api.nvim_set_hl(0, "BufferLineFill", { fg = comment.fg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "BufferLineBackground", { fg = comment.fg, bg = normal.bg })

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

      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(vim.fn.stdpath("config") .. "/lua", {}, function(err, filename)
          if err or filename ~= "matugen.lua" then return end
          vim.schedule(function()
            vim.defer_fn(apply, 150)
          end)
        end)
      end

      apply()
    '';
  };
}
