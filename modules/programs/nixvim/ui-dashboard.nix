{ lib, ... }:
let
  # The splash image, copied into the Nix store at build time. Lua gets its store path.
  image = ./assets/lain-the-thinker.png;

  # Blank rows reserved for the image. The image is drawn over these rows.
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
            (button "q" "Quit" "vim.cmd('qa')")
          ];
          opts.spacing = 1;
        }
      ];
    };

    # Draws the splash image on the dashboard. It runs after alpha draws, so the image
    # isn't overwritten by alpha's own redraw. It also redraws on resize.
    extraConfigLuaPost = lib.mkAfter ''
      local img_path = "${image}"
      local shown = nil

      local function clear_shown()
        if shown then
          pcall(function() shown:clear() end)
          shown = nil
        end
      end

      local function show()
        if vim.bo.filetype ~= "alpha" then
          clear_shown()
          return
        end
        local ok, api = pcall(require, "image")
        if not ok then return end

        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        clear_shown()

        local width, height = 36, 16
        local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - width) / 2))
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

      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinResized", "VimResized" }, {
        callback = function() vim.defer_fn(show, 30) end,
      })
    '';
  };
}
