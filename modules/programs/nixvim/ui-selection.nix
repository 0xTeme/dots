{ lib, ... }:
{
  # Yazi-style selection for the file tree and the splash screen. The selected row gets a
  # capsule: the row background with sharp half-block caps at each end, the same look as
  # yazi's selection. Colours come from the palette's own CursorLine, not a blend. Other
  # buffers keep their normal cursor. The terminal cursor is hidden only in these two.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    extraConfigLuaPost = lib.mkAfter ''
      local ns = vim.api.nvim_create_namespace("navi_selection")
      local hidden_cursor = "NaviHiddenCursor"
      local default_guicursor = vim.o.guicursor
      local targets = { NvimTree = true, alpha = true }

      -- Colours for the capsule, read from the palette on every colorscheme change.
      local function apply_groups()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        local cline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
        local accent = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })
        local sel_bg = cline.bg or normal.bg
        -- Caps are drawn in the selection colour on the editor background.
        vim.api.nvim_set_hl(0, "NaviCap", { fg = sel_bg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "NaviSelection", { fg = accent.fg, bg = sel_bg, bold = true })
        vim.api.nvim_set_hl(0, hidden_cursor, { blend = 100, nocombine = true })
      end

      -- Draws the capsule on the cursor's row only. Previous capsules are cleared first.
      local function draw(buf, win)
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        local row = vim.api.nvim_win_get_cursor(win)[1] - 1
        local text = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
          end_row = row + 1,
          hl_group = "NaviSelection",
          hl_eol = true,
        })
        -- Left cap sits before the text, right cap at the end of the line.
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
          virt_text = { { "▐", "NaviCap" } },
          virt_text_pos = "inline",
        })
        vim.api.nvim_buf_set_extmark(buf, ns, row, #text, {
          virt_text = { { "▌", "NaviCap" } },
          virt_text_pos = "eol",
        })
      end

      local function on_move()
        local buf = vim.api.nvim_get_current_buf()
        if targets[vim.bo[buf].filetype] then
          draw(buf, vim.api.nvim_get_current_win())
        end
      end

      -- Hides the terminal cursor in the targets, and restores it everywhere else.
      local function on_enter()
        if targets[vim.bo.filetype] then
          vim.o.guicursor = "n-v-c:block-" .. hidden_cursor
        else
          vim.o.guicursor = default_guicursor
        end
      end

      apply_groups()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_groups })
      vim.api.nvim_create_autocmd({ "CursorMoved", "FileType", "BufEnter" }, { callback = on_move })
      vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, { callback = on_enter })
      on_move()
      on_enter()
    '';
  };
}
