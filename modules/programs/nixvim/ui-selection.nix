{ lib, ... }:
{
  # Yazi-style selection for the file tree and the splash screen. The capsule wraps only the
  # text, with sharp half-block caps. Caps are overlays on the spaces beside the text, so
  # nothing shifts. The capsule is drawn only in the focused window, and the terminal cursor
  # is hidden in these two buffers, so the capsule is the one focus marker. On the splash,
  # j and k move between button lines only.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    extraConfigLuaPost = lib.mkAfter ''
      local ns = vim.api.nvim_create_namespace("navi_selection")
      local targets = { NvimTree = true, alpha = true }
      local default_guicursor = vim.o.guicursor

      -- Colours come from the palette, read again on every colorscheme change.
      local function apply_groups()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        local cline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
        local accent = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })
        local sel_bg = cline.bg or normal.bg
        vim.api.nvim_set_hl(0, "NaviCap", { fg = sel_bg, bg = normal.bg })
        vim.api.nvim_set_hl(0, "NaviSelection", { fg = accent.fg, bg = sel_bg, bold = true })
        vim.api.nvim_set_hl(0, "NaviHiddenCursor", { blend = 100, nocombine = true })
      end

      local function clear(buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end
      end

      -- Draws the capsule on the cursor's row, and only in the focused window.
      local function draw(buf, win)
        if win ~= vim.api.nvim_get_current_win() then return end
        clear(buf)
        local row = vim.api.nvim_win_get_cursor(win)[1] - 1
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""

        -- Byte columns, 0-based: text starts at start_col and stops before stop_col.
        local start_col = (line:find("%S") or 1) - 1
        local stop_col = (line:match("()%s*$") or (#line + 1)) - 1
        if stop_col <= start_col then return end

        vim.api.nvim_buf_set_extmark(buf, ns, row, start_col, {
          end_row = row,
          end_col = stop_col,
          hl_group = "NaviSelection",
        })

        -- Left cap overlays the space just before the text, if there is one.
        if start_col >= 1 and line:sub(start_col, start_col) == " " then
          vim.api.nvim_buf_set_extmark(buf, ns, row, start_col - 1, {
            virt_text = { { "▐", "NaviCap" } },
            virt_text_pos = "overlay",
          })
        end

        -- Right cap overlays the space just after the text. If the text runs to the line end,
        -- the cap sits after the line instead, which moves nothing.
        if stop_col < #line and line:sub(stop_col + 1, stop_col + 1) == " " then
          vim.api.nvim_buf_set_extmark(buf, ns, row, stop_col, {
            virt_text = { { "▌", "NaviCap" } },
            virt_text_pos = "overlay",
          })
        else
          vim.api.nvim_buf_set_extmark(buf, ns, row, #line, {
            virt_text = { { "▌", "NaviCap" } },
            virt_text_pos = "eol",
          })
        end
      end

      local function on_move()
        local buf = vim.api.nvim_get_current_buf()
        if targets[vim.bo[buf].filetype] then
          draw(buf, vim.api.nvim_get_current_win())
        end
      end

      -- Hides the terminal cursor in the splash and the tree. Other buffers keep theirs.
      local function on_enter()
        if targets[vim.bo.filetype] then
          vim.o.guicursor = "n-v-c:block-NaviHiddenCursor"
        else
          vim.o.guicursor = default_guicursor
        end
      end

      -- A button line ends with a single shortcut letter, like "New file    e".
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
      vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
        callback = on_enter,
      })

      -- Leaving a window removes its capsule, so only the focused pane shows one.
      vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
          clear(vim.api.nvim_get_current_buf())
        end,
      })

      on_move()
      on_enter()
    '';
  };
}
