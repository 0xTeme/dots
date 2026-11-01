{ lib, ... }:
{
  # Yazi-style selection for the file tree and the splash screen. The selected row is a
  # capsule: the selection background with sharp half-block caps at each end. It's drawn
  # only in the focused window, so the pane with the capsule is the one with focus, and the
  # terminal cursor stays visible for the same reason. On the splash, j and k move between
  # button lines only, skipping the blank rows and the header.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    extraConfigLuaPost = lib.mkAfter ''
      local ns = vim.api.nvim_create_namespace("navi_selection")
      local targets = { NvimTree = true, alpha = true }

      -- Colours come from the palette, read again on every colorscheme change.
      local function apply_groups()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        local cline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
        local accent = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })
        local sel_bg = cline.bg or normal.bg
        vim.api.nvim_set_hl(0, "NaviCap", { fg = sel_bg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "NaviSelection", { fg = accent.fg, bg = sel_bg, bold = true })
      end

      local function clear(buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end
      end

      -- Draws the capsule on the cursor's row, but only in the focused window.
      local function draw(buf, win)
        if win ~= vim.api.nvim_get_current_win() then return end
        clear(buf)
        local row = vim.api.nvim_win_get_cursor(win)[1] - 1
        local text = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
          end_row = row + 1,
          hl_group = "NaviSelection",
          hl_eol = true,
        })
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

      -- A button line ends with a single shortcut letter after spaces, like "New file   e".
      local function is_button(line)
        return line:match("%s[a-z]%s*$") ~= nil
      end

      -- Moves to the next or previous button line, skipping everything else.
      local function step(dir)
        return function()
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_get_current_buf()
          local r = vim.api.nvim_win_get_cursor(win)[1] + dir
          local total = vim.api.nvim_buf_line_count(buf)
          while r >= 1 and r <= total do
            local line = vim.api.nvim_buf_get_lines(buf, r - 1, r, false)[1] or ""
            if is_button(line) then
              vim.api.nvim_win_set_cursor(win, { r, 3 })
              return
            end
            r = r + dir
          end
        end
      end

      apply_groups()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_groups })

      -- Splash: j and k only land on buttons.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function(args)
          vim.keymap.set("n", "j", step(1), { buffer = args.buf, silent = true })
          vim.keymap.set("n", "k", step(-1), { buffer = args.buf, silent = true })
        end,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "FileType", "BufEnter", "WinEnter" }, {
        callback = on_move,
      })

      -- Leaving a window removes its capsule, so only the focused pane shows one.
      vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
          clear(vim.api.nvim_get_current_buf())
        end,
      })

      on_move()
    '';
  };
}
