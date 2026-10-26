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

    # Draws one splash image on the dashboard. Each redraw is debounced, so a burst of
    # resize and window events runs a single draw after things settle. Every draw first
    # clears all rendered images with the plugin's module-level clear, so the old image
    # is removed before the new one is placed.
    extraConfigLuaPost = lib.mkAfter ''
      -- A user image wins over the repo default, so it can be swapped without a rebuild.
      local data_home = vim.env.XDG_DATA_HOME or (vim.env.HOME .. "/.local/share")
      local user_img = data_home .. "/navi/splash.png"
      local img_path = (vim.uv.fs_stat(user_img) and user_img) or "${image}"

      local state_file = vim.fn.stdpath("state") .. "/navi-splash-image"
      local rows = ${toString imageRows}
      local bottom_gap = ${toString headerBottomGap}
      local shown = false

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

      -- Removes every rendered image through the plugin's module-level clear.
      local function clear_image()
        local ok, api = pcall(require, "image")
        if ok and api.clear then
          pcall(api.clear)
        end
        shown = false
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

      -- One draw: clear, then place a single image if the dashboard is open and enabled.
      local function show()
        local win, buf = dashboard()
        if not win then
          -- The dashboard is gone. Remove our image only if we were the ones showing it.
          if shown then clear_image() end
          return
        end

        clear_image()
        if not enabled() then return end

        local ok, api = pcall(require, "image")
        if not ok then return end

        local width, height = 36, rows
        local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - width) / 2))

        local img = api.from_file(img_path, {
          window = win,
          buffer = buf,
          x = col,
          y = 2,
          width = width,
          height = height,
        })
        if img then
          pcall(function() img:render() end)
          shown = true
        end
      end

      -- Debounce: any number of events inside the window run one draw, after the last one.
      local timer = vim.uv.new_timer()
      local function schedule_show()
        timer:stop()
        timer:start(120, 0, vim.schedule_wrap(show))
      end

      -- Called by the "Toggle image" button. Swaps the image and the header, then redraws.
      function NaviToggleImage()
        save(not enabled())
        clear_image()
        pcall(function() require("alpha").redraw() end)
        schedule_show()
      end

      vim.api.nvim_create_autocmd(
        { "ColorScheme", "FileType", "BufWinEnter", "BufWinLeave", "WinEnter", "WinNew", "WinClosed", "WinResized", "VimResized" },
        { callback = schedule_show }
      )
    '';
  };
}
