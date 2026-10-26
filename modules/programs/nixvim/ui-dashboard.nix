{ lib, ... }:
let
  # The splash image, copied into the Nix store at build time. Lua gets its store path.
  image = ./assets/lain-the-thinker.png;

  # Rows shared by the image and the NAVI header. Only one of them shows at a time.
  imageRows = 16;

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
          # centered in the same rows. Alpha calls this function on every redraw.
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

    # Draws the splash image on the dashboard window itself, and swaps it with the NAVI
    # header. The on/off choice is saved in the state directory.
    extraConfigLuaPost = lib.mkAfter ''
      local img_path = "${image}"
      local state_file = vim.fn.stdpath("state") .. "/navi-splash-image"
      local rows = ${toString imageRows}
      local shown = nil

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
        local top = math.floor((rows - #header) / 2)
        for i, line in ipairs(header) do
          out[top + i] = line
        end
        return out
      end

      local function clear_shown()
        if shown then
          pcall(function() shown:clear() end)
          shown = nil
        end
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

      local function show()
        local win, buf = dashboard()
        if not win or not enabled() then
          clear_shown()
          return
        end
        local ok, api = pcall(require, "image")
        if not ok then return end

        local width, height = 36, rows
        local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - width) / 2))

        if shown then
          pcall(function()
            shown:render({ x = col, y = 2, width = width, height = height })
          end)
          return
        end

        shown = api.from_file(img_path, {
          window = win,
          buffer = buf,
          x = col,
          y = 2,
          width = width,
          height = height,
        })
        pcall(function() shown:render() end)
      end

      -- Called by the "Toggle image" button. Swaps the image and the header, then redraws.
      function NaviToggleImage()
        save(not enabled())
        clear_shown()
        pcall(function() require("alpha").redraw() end)
        vim.defer_fn(show, 30)
      end

      vim.api.nvim_create_autocmd(
        { "FileType", "BufWinEnter", "WinEnter", "WinNew", "WinClosed", "WinResized", "VimResized" },
        { callback = function() vim.defer_fn(show, 30) end }
      )
    '';
  };
}
