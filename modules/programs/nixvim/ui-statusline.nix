{ lib, ... }:
{
  # Bottom bar and tab row, colored from the palette's real highlight groups, the way Omarchy
  # and LazyVim theme lualine: each mode's badge uses its role's exact color, with the editor
  # background as the text. Lualine needs "#rrggbb" strings, so Neovim's numeric colors are
  # converted at the point of use.
  #
  # The palette reload rewrites matugen.lua, then applies the colors a moment later. Reading
  # too early gives the previous palette, so after a change the bar checks the real colors
  # and applies only once they differ from what it last drew. It retries for a few seconds,
  # so it doesn't depend on the exact timing. mkAfter runs this after the palette loads.
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

      -- The colors this bar was last drawn with. A change in any of them means a new palette.
      local last = nil

      local function signature()
        local n = hl("Normal")
        local k = hl("Keyword")
        return table.concat({ n.bg or 0, n.fg or 0, k.fg or 0, hl("String").fg or 0, hl("Comment").fg or 0 }, ":")
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
        if ok then
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

        last = signature()
      end

      -- Applies only when the real colors have changed since the last draw.
      local function sync()
        if signature() ~= last then
          apply()
        end
      end

      -- A palette change: check now, then keep checking for a few seconds until it lands.
      local function on_palette_change()
        for _, delay in ipairs({ 0, 150, 400, 800, 1500, 2500 }) do
          vim.defer_fn(sync, delay)
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })

      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(vim.fn.stdpath("config") .. "/lua", {}, function(err, filename)
          if err or filename ~= "matugen.lua" then return end
          vim.schedule(on_palette_change)
        end)
      end

      apply()
    '';
  };
}
