{ lib, ... }:
let
  # The default splash image, in the repo. To change it, replace splash.png here and rebuild,
  # or put any image at ~/.local/share/navi/splash.png and reopen Neovim, with no rebuild.
  image = ./assets/splash.png;

  # Rows shared by the image and the NAVI header. Only one of them shows at a time.
  imageRows = 16;

  # Blank rows left under the NAVI header inside that block. A smaller number moves the
  # header down, closer to the list. A larger number moves it up.
  headerBottomGap = 2;

  # letter: the single key shown and bound. label: the text. lua: the action.
  button = letter: label: lua: {
    type = "button";
    val = label;
    on_press = { __raw = "function() ${lua} end"; };
    opts = {
      position = "center";
      shortcut = letter;
      cursor = 3;
      width = 30;
      align_shortcut = "right";
      hl_shortcut = "Keyword";
      keymap = [
        "n"
        letter
        "<cmd>lua ${lua}<CR>"
        { noremap = true; silent = true; nowait = true; }
      ];
    };
  };
in
{
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.alpha = {
      enable = true;
      settings.layout = [
        { type = "padding"; val = 2; }
        {
          # Image on: blank rows, with the image drawn over them. Image off: the NAVI header,
          # placed in the same rows. Alpha calls this function on every redraw.
          type = "text";
          val = { __raw = "function() return NaviSplashRows() end"; };
          opts = {
            position = "center";
            hl = "Keyword";
          };
        }
        { type = "padding"; val = 2; }
        {
          type = "text";
          val = "────────────────────────────";
          opts = {
            position = "center";
            hl = "Comment";
          };
        }
        { type = "padding"; val = 1; }
        {
          type = "group";
          val = [
            (button "e" "New file" "vim.cmd('enew')")
            (button "f" "Find file" "require('fzf-lua').files()")
            (button "r" "Recent files" "require('fzf-lua').oldfiles()")
            (button "g" "Find word" "require('fzf-lua').live_grep()")
            (button "i" "Toggle image" "NaviToggleImage()")
            (button "q" "Quit" "vim.cmd('qa')")
          ];
          opts.spacing = 1;
        }
        { type = "padding"; val = 1; }
        {
          type = "text";
          val = "────────────────────────────";
          opts = {
            position = "center";
            hl = "Comment";
          };
        }
      ];
    };

    # One placement per change. Changes are debounced, so a burst of events runs once. A
    # window-size change moves the existing image; it isn't cleared and drawn again. A theme
    # change, a toggle, or a fresh dashboard clears and places once, after a short delay that
    # lets alpha finish its own redraw.
    extraConfigLuaPost = lib.mkAfter ''
      -- A user image wins over the repo default, so it can be swapped without a rebuild.
      local data_home = vim.env.XDG_DATA_HOME or (vim.env.HOME .. "/.local/share")
      local user_img = data_home .. "/navi/splash.png"
      local img_path = (vim.uv.fs_stat(user_img) and user_img) or "${image}"

      local state_file = vim.fn.stdpath("state") .. "/navi-splash-image"
      local rows = ${toString imageRows}
      local bottom_gap = ${toString headerBottomGap}
      local width = 36

      -- The image this module placed last, as { img, win, buf, x }, or nil.
      local current = nil

      local header = {
        "███╗   ██╗ █████╗ ██╗   ██╗██╗",
        "████╗  ██║██╔══██╗██║   ██║██║",
        "██╔██╗ ██║███████║██║   ██║██║",
        "██║╚██╗██║██╔══██║╚██╗ ██╔╝██║",
        "██║ ╚████║██║  ██║ ╚████╔╝ ██║",
        "╚═╝  ╚═══╝╚═╝  ╚═╝  ╚═══╝  ╚═╝",
      }

      local function enabled()
        local f = io.open(state_file, "r")
        if not f then return true end
        local v = f:read("*l")
        f:close()
        return v ~= "0"
      end

      local function save(on)
        local f = io.open(state_file, "w")
        if f then
          f:write(on and "1" or "0")
          f:close()
        end
      end

      -- What the image slot shows. Called by alpha on every redraw.
      function NaviSplashRows()
        local out = {}
        for i = 1, rows do out[i] = " " end
        if enabled() then
          return out
        end
        local top = rows - #header - bottom_gap
        for i, line in ipairs(header) do
          out[top + i] = line
        end
        return out
      end

      -- Removes every image the plugin has drawn, not just ours.
      local function clear_all()
        local ok, api = pcall(require, "image")
        if ok and api.clear then
          pcall(api.clear)
        end
        if ok and api.get_images then
          for _, img in ipairs(api.get_images()) do
            pcall(function() img:clear() end)
          end
        end
        current = nil
      end

      -- Finds the dashboard window, wherever focus is.
      local function dashboard()
        for _, w in ipairs(vim.api.nvim_list_wins()) do
          local b = vim.api.nvim_win_get_buf(w)
          if vim.bo[b].filetype == "alpha" then
            return w, b
          end
        end
        return nil, nil
      end

      -- Brings the screen in line with the state. With force, the image is cleared and placed
      -- again. Without force, it moves only when the dashboard's column changed.
      local function show(force)
        local win, buf = dashboard()
        if not win or not enabled() then
          clear_all()
          return
        end

        local ok, api = pcall(require, "image")
        if not ok then return end

        local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - width) / 2))

        if not force and current and current.win == win and current.buf == buf then
          if current.x ~= col then
            current.x = col
            pcall(function()
              current.img:render({ x = col, y = 2, width = width, height = rows })
            end)
          end
          return
        end

        clear_all()
        local img = api.from_file(img_path, {
          window = win,
          buffer = buf,
          x = col,
          y = 2,
          width = width,
          height = rows,
        })
        if img then
          pcall(function() img:render() end)
          current = { img = img, win = win, buf = buf, x = col }
        end
      end

      -- Debounced entry point. Any number of calls in the window run one show, after the
      -- last call. A forced call waits longer, so alpha's own redraw happens first.
      local timer = vim.uv.new_timer()
      local pending_force = false
      local function schedule(force, delay)
        pending_force = pending_force or force
        timer:stop()
        timer:start(delay or 80, 0, vim.schedule_wrap(function()
          local f = pending_force
          pending_force = false
          show(f)
        end))
      end

      -- Called by the "Toggle image" button. Swaps the image and the header, then redraws.
      function NaviToggleImage()
        save(not enabled())
        clear_all()
        pcall(function() require("alpha").redraw() end)
        schedule(true, 250)
      end

      -- A theme change clears and places once, after alpha has redrawn.
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function() schedule(true, 250) end,
      })

      -- The palette reload rewrites matugen.lua and can skip the ColorScheme event.
      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(vim.fn.stdpath("config") .. "/lua", {}, function(err, filename)
          if err or filename ~= "matugen.lua" then return end
          vim.schedule(function() schedule(true, 250) end)
        end)
      end

      -- A fresh dashboard gets one placement.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if vim.bo[args.buf].filetype == "alpha" then schedule(true, 250) end
        end,
      })

      -- Window and size events move the image, without clearing it.
      vim.api.nvim_create_autocmd(
        { "BufWinEnter", "BufWinLeave", "WinEnter", "WinClosed", "WinResized", "VimResized" },
        { callback = function() schedule(false, 80) end }
      )
    '';
  };
}
