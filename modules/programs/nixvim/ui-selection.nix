{ lib, ... }:
{
  # Selection for the file tree and the splash screen, in the selection colour. Both get one
  # padding cell on the left. Both also get one padding cell after the text: on the tree and the
  # splash alike, that cell is end-of-line virtual text when the line has no real space after the
  # text, which is the same mechanism the tree has always used. The highlight is drawn only in the
  # focused window, and the terminal cursor is hidden in these two buffers. On the splash, j and k
  # move between button lines only.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    extraConfigLuaPost = lib.mkAfter ''
      local ns = vim.api.nvim_create_namespace("navi_selection")
      local pad_ns = vim.api.nvim_create_namespace("navi_tree_pad")
      local targets = { NvimTree = true, alpha = true }
      local default_guicursor = vim.o.guicursor

      -- Colours come from the palette, read again on every colorscheme change.
      local function apply_groups()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        local cline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
        local accent = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })
        local sel_bg = cline.bg or normal.bg
        vim.api.nvim_set_hl(0, "NaviSelection", { fg = accent.fg, bg = sel_bg, bold = true })
        vim.api.nvim_set_hl(0, "NaviHiddenCursor", { blend = 100, nocombine = true })
      end

      -- Tree: the left pad on every line, selected row highlighted, the rest Normal.
      local function pad_tree(buf, sel_row)
        if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "NvimTree" then return end
        vim.api.nvim_buf_clear_namespace(buf, pad_ns, 0, -1)
        local total = vim.api.nvim_buf_line_count(buf)
        for row = 0, total - 1 do
          local hl = (row == sel_row) and "NaviSelection" or "Normal"
          vim.api.nvim_buf_set_extmark(buf, pad_ns, row, 0, {
            virt_text = { { " ", hl } },
            virt_text_pos = "inline",
          })
        end
      end

      local function clear(buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
          pad_tree(buf, nil)
        end
      end

      -- Display cell where byte b of the line starts.
      local function cell_of_byte(line, b)
        return vim.fn.strdisplaywidth(line:sub(1, b))
      end

      -- Byte index of the first character that starts at or after display cell target.
      local function byte_at_cell(line, target)
        local col = 0
        local n = vim.fn.strchars(line)
        for i = 0, n - 1 do
          if col >= target then return vim.fn.byteidx(line, i) end
          col = col + vim.fn.strdisplaywidth(vim.fn.strcharpart(line, i, 1))
        end
        return #line
      end

      -- Splash: one cell before the text, the text itself, and one cell after it.
      local function draw_splash(buf, row, line)
        local s_b = (line:find("%S") or 1) - 1
        local e_b = (line:match("()%s*$") or (#line + 1)) - 1
        if e_b <= s_b then return end

        local s_c = cell_of_byte(line, s_b)
        local start_byte = byte_at_cell(line, math.max(0, s_c - 1))

        vim.api.nvim_buf_set_extmark(buf, ns, row, start_byte, {
          end_row = row,
          end_col = e_b,
          hl_group = "NaviSelection",
        })

        -- The cell after the text. With no real space there, the pad is end-of-line text.
        if e_b >= #line then
          vim.api.nvim_buf_set_extmark(buf, ns, row, #line, {
            virt_text = { { " ", "NaviSelection" } },
            virt_text_pos = "eol",
          })
        end
      end

      -- Tree: the text span plus one cell each side. Its icons have no multi-byte characters
      -- after them, so byte columns match cell columns here.
      local function draw_tree(buf, row, line)
        local s = (line:find("%S") or 1) - 1
        local e = (line:match("()%s*$") or (#line + 1)) - 1
        if e <= s then return end
        pad_tree(buf, row)

        local hl_start = math.max(0, s - 1)
        local hl_stop = math.min(#line, e + 1)
        vim.api.nvim_buf_set_extmark(buf, ns, row, hl_start, {
          end_row = row,
          end_col = hl_stop,
          hl_group = "NaviSelection",
        })
        if e >= #line then
          vim.api.nvim_buf_set_extmark(buf, ns, row, #line, {
            virt_text = { { " ", "NaviSelection" } },
            virt_text_pos = "eol",
          })
        end
      end

      -- Draws the highlight on the cursor's row, and only in the focused window.
      local function draw(buf, win)
        if win ~= vim.api.nvim_get_current_win() then return end
        clear(buf)
        local row = vim.api.nvim_win_get_cursor(win)[1] - 1
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
        if vim.bo[buf].filetype == "alpha" then
          draw_splash(buf, row, line)
        else
          draw_tree(buf, row, line)
        end
      end

      local function on_move()
        local buf = vim.api.nvim_get_current_buf()
        local ft = vim.bo[buf].filetype
        if ft == "NvimTree" or ft == "alpha" then
          draw(buf, vim.api.nvim_get_current_win())
        end
      end

      -- The tree's pads are rebuilt whenever the tree changes, since nvim-tree rewrites its lines.
      local function on_tree_change()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].filetype == "NvimTree" then
          pad_tree(buf, nil)
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

      vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "WinEnter" }, { callback = on_move })
      vim.api.nvim_create_autocmd({ "TextChanged", "BufWinEnter", "FileType" }, { callback = on_tree_change })
      vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, { callback = on_enter })

      -- Leaving a window removes its highlight, so only the focused pane shows one.
      vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
          clear(vim.api.nvim_get_current_buf())
        end,
      })

      on_tree_change()
      on_move()
      on_enter()
    '';
  };
}
