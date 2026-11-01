{ lib, ... }:
{
  # Sharp-cornered selection for the file tree and the splash screen, in the selection colour,
  # with one padding cell on each side of the text. On the splash, the padding is drawn over the
  # real space cells beside the text, so it doesn't depend on how many trailing spaces alpha
  # leaves. On the tree, the left pad is a virtual cell on every line, since the icons start at
  # column 0. The highlight is drawn only in the focused window, and the terminal cursor is
  # hidden in these two buffers. On the splash, j and k move between button lines only.
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

      -- Sets the tree's one-column left pad on every line. The selected row gets the selection
      -- colour, every other row gets Normal, so the pad is blank unless it's selected.
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

      -- Removes the highlight and resets the tree's pad. Called when leaving a window.
      local function clear(buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
          pad_tree(buf, nil)
        end
      end

      -- Splash: the text span gets the highlight. The cell before it and the cell after it are
      -- overlaid with the selection colour when they're real spaces. At the end of the line,
      -- there's no cell, so the pad is virtual text there instead.
      local function draw_splash(buf, row, line)
        -- Byte columns, 0-based: the text runs from s up to, not including, e.
        local s = (line:find("%S") or 1) - 1
        local e = (line:match("()%s*$") or (#line + 1)) - 1
        if e <= s then return end

        vim.api.nvim_buf_set_extmark(buf, ns, row, s, {
          end_row = row,
          end_col = e,
          hl_group = "NaviSelection",
        })

        -- Left pad: the cell at s-1 is line:sub(s, s) in Lua's 1-based indexing.
        if s >= 1 and line:sub(s, s) == " " then
          vim.api.nvim_buf_set_extmark(buf, ns, row, s - 1, {
            virt_text = { { " ", "NaviSelection" } },
            virt_text_pos = "overlay",
          })
        end

        -- Right pad: the cell at e is line:sub(e + 1, e + 1).
        if e < #line and line:sub(e + 1, e + 1) == " " then
          vim.api.nvim_buf_set_extmark(buf, ns, row, e, {
            virt_text = { { " ", "NaviSelection" } },
            virt_text_pos = "overlay",
          })
        else
          vim.api.nvim_buf_set_extmark(buf, ns, row, #line, {
            virt_text = { { " ", "NaviSelection" } },
            virt_text_pos = "eol",
          })
        end
      end

      -- Tree: the text span plus one cell on each side, with the left pad already virtual.
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
