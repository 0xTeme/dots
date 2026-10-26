{ lib, ... }:
let
  # The splash image, copied into the Nix store at build time. Lua gets its store path.
  image = ./assets/lain-the-thinker.png;

  # Blank rows reserved for the image. They stay reserved when the image is off, so the
  # header doesn't move when you toggle.
  imageRows = 16;

  header = [
    "███╗   ██╗ █████╗ ██╗   ██╗██╗"
    "████╗  ██║██╔══██╗██║   ██║██║"
    "██╔██╗ ██║███████║██║   ██║██║"
    "██║╚██╗██║██╔══██║╚██╗ ██╔╝██║"
    "██║ ╚████║██║  ██║ ╚████╔╝ ██║"
    "╚═╝  ╚═══╝╚═╝  ╚═╝  ╚═══╝  ╚═╝"
  ];

  # letter: the single key shown and bound. label: the text. lua: the action.
  button = letter: label: lua: {
    type = "button";
    val = label;
    on_press = { __raw = "function() ${lua} end"; };
    opts = {
      position = "center";
      shortcut = letter;
      cursor = 3;
      width = 40;
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
        { type = "padding"; val = 1; }
        {
          type = "text";
          val = builtins.genList (_: " ") imageRows;
          opts.position = "center";
        }
        { type = "padding"; val = 2; }
        {
          type = "text";
          val = header;
          opts = {
            position = "center";
            hl = "Keyword";
          };
        }
        { type = "padding"; val = 3; }
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
      ];
    };

    # Draws the splash image, and keeps one image alive across resizes instead of making a
    # new one each time. The on/off choice is saved in the state directory.
    extraConfigLuaPost = lib.mkAfter ''
      local img_path = "${image}"
      local state_file = vim.fn.stdpath("state") .. "/navi-splash-image"
      local shown = nil

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

      local function clear_shown()
        if shown then
          pcall(function() shown:clear() end)
          shown = nil
        end
      end

      local function show()
        if vim.bo.filetype ~= "alpha" or not enabled() then
          clear_shown()
          return
        end
        local ok, api = pcall(require, "image")
        if not ok then return end

        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        local width, height = 36, 16
        local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - width) / 2))

        if shown then
          -- Already drawn: move the same image instead of creating another.
          pcall(function()
            shown:render({ x = col, y = 1, width = width, height = height })
          end)
          return
        end

        shown = api.from_file(img_path, {
          window = win,
          buffer = buf,
          x = col,
          y = 1,
          width = width,
          height = height,
        })
        pcall(function() shown:render() end)
      end

      -- Called by the "Toggle image" button.
      function NaviToggleImage()
        save(not enabled())
        clear_shown()
        show()
      end

      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinResized", "VimResized" }, {
        callback = function() vim.defer_fn(show, 30) end,
      })
    '';
  };
}
