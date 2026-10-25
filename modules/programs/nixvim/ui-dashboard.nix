{
  # Startup dashboard: a block-letter header and buttons that open fzf-lua pickers.
  # To change the header, replace the lines in the `header` list below. Keep every
  # line the same width so the centering stays even.
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

      button = label: shortcut: lua: {
        type = "button";
        val = label;
        on_press = { __raw = "function() ${lua} end"; };
        opts = {
          position = "center";
          shortcut = shortcut;
          cursor = 3;
          width = 44;
          align_shortcut = "right";
          hl_shortcut = "Keyword";
        };
      };
    in
    {
      enable = true;
      layout = [
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
            (button "  New file" "e" "vim.cmd('enew')")
            (button "  Find file" "SPC f f" "require('fzf-lua').files()")
            (button "  Recent files" "SPC f h" "require('fzf-lua').oldfiles()")
            (button "  Find word" "SPC f g" "require('fzf-lua').live_grep()")
            (button "  Quit" "q" "vim.cmd('qa')")
          ];
          opts.spacing = 1;
        }
      ];
    };
}
