{ lib, ... }:
{
  # File tree styled like the `tree` command: ├─ and └─ connectors with │ edges, file-type
  # icons, and git status next to changed files. Colors are links to the palette's roles,
  # so they follow every palette change. The tree is read-only, so typing in it shows E21.
  # Move focus to the editor with Ctrl+w l.
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
            # Two spaces after each icon, so the glyphs read as larger and separate.
            padding = "  ";
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

    extraConfigLuaPost = lib.mkAfter ''
      -- Each group links to a palette role, so it follows the palette on every change.
      -- Colorscheme loads reset highlight groups, so the links are reapplied on each one.
      local function tree_colors()
        local set = vim.api.nvim_set_hl
        set(0, "NvimTreeRootFolder", { link = "Keyword", bold = true })
        set(0, "NvimTreeOpenedFolderName", { link = "Keyword", bold = true })
        set(0, "NvimTreeFolderName", { link = "Keyword" })
        set(0, "NvimTreeFolderIcon", { link = "Keyword", bold = true })
        set(0, "NvimTreeFileName", { link = "Normal" })
        set(0, "NvimTreeIndentMarker", { link = "Comment" })
        set(0, "NvimTreeWinSeparator", { link = "Comment" })
      end

      vim.api.nvim_create_autocmd("ColorScheme", { callback = tree_colors })
      tree_colors()
    '';
  };
}
