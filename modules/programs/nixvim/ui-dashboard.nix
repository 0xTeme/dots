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

    # The image plugin keeps its own list of every image it has drawn, so clearing one
    # handle isn't enough. Each clear here removes everything in that list. The image is
    # drawn only while the dashboard is on screen, and cleared everywhere else.
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

      -- Removes every image the plugin has drawn, not just ours. Falls back to clearing each
      -- entry in its list if the module-level clear isn't available.
      local function clear_all()
        local ok, api = pcall(require, "image")
        if not ok then return end
        if api.clear then
          pcall(api.clear)
        end
        if api.get_images then
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

      -- One draw: clear everything, then place a single image if the dashboard is on screen.
      -- With no dashboard, everything is cleared and nothing is drawn.
      local function show()
        local win, buf = dashboard()
        clear_all()
        if not win or not enabled() then return end

        local ok, api = pcall(require, "image")
        if not ok then return end

        local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - width) / 2))
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

      -- Debounce for window events: a burst runs one draw, after the last event.
      local timer = vim.uv.new_timer()
      local function schedule()
        timer:stop()
        timer:start(80, 0, vim.schedule_wrap(show))
      end

      -- After a palette change or a fresh dashboard, draw at a few delays. Alpha redraws on
      -- its own schedule, and any redraw can clear an image placed just before it.
      local function palette_refresh()
        clear_all()
        for _, delay in ipairs({ 0, 300, 900, 1800 }) do
          vim.defer_fn(show, delay)
        end
      end

      -- Called by the "Toggle image" button. Swaps the image and the header, then redraws.
      function NaviToggleImage()
        save(not enabled())
        clear_all()
        pcall(function() require("alpha").redraw() end)
        palette_refresh()
      end

      vim.api.nvim_create_autocmd("ColorScheme", { callback = palette_refresh })

      -- The palette reload rewrites matugen.lua and can skip the ColorScheme event.
      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(vim.fn.stdpath("config") .. "/lua", {}, function(err, filename)
          if err or filename ~= "matugen.lua" then return end
          vim.schedule(palette_refresh)
        end)
      end

      -- A fresh dashboard gets its image after alpha has drawn it.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if vim.bo[args.buf].filetype == "alpha" then palette_refresh() end
        end,
      })

      -- Window and size events only move the image, debounced.
      vim.api.nvim_create_autocmd(
        { "BufWinEnter", "BufWinLeave", "WinEnter", "WinClosed", "WinResized", "VimResized" },
        { callback = schedule }
      )
    '';
  };
}
