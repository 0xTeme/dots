{
  # File tree styled like the `tree` command: ├─ and └─ connectors with │ edges. Shows
  # file-type icons, the folder icon, and git status next to changed files. The buffer
  # isn't editable, so typing in it shows E21. Move focus to the editor with Ctrl+w l.
  flake.modules.homeManager.nixvim.programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      settings = {
        view.width = 32;
        renderer = {
          indent_width = 3;
          root_folder_label = ":~:s?$?/..?";
          highlight_git = "name";
          highlight_opened_files = "name";
          icons = {
            padding = " ";
            show = {
              file = true;
              folder = true;
              folder_arrow = false;
              git = true;
            };
            glyphs.git = {
              unstaged = "●";
              staged = "✓";
              unmerged = "≠";
              renamed = "➜";
              untracked = "★";
              deleted = "✗";
              ignored = "◌";
            };
          };
          indent_markers = {
            enable = true;
            inline_arrows = false;
            icons = {
              corner = "└─";
              edge = "│ ";
              item = "├─";
              bottom = "─";
              none = "  ";
            };
          };
        };
      };
    };

    keymaps = [
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<CR>"; options.desc = "Toggle file explorer"; }
    ];
  };
}
