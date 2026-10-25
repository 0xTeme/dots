{
  # Startup dashboard: a block-letter header and single-letter shortcuts. Each shortcut
  # is a real keymap in the dashboard buffer, so pressing the letter runs the action.
  # To change the header, replace the lines in the `header` list. Keep every line the
  # same width so the centering stays even.
  flake.modules.homeManager.nixvim.programs.nixvim.plugins.alpha =
    let
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
      enable = true;
      settings.layout = [
        { type = "padding"; val = 3; }
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
}
