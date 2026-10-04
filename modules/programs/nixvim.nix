{ inputs, ... }:
{
  flake.modules.homeManager.nixvim = { config, pkgs, ... }: {
    imports = [ inputs.nixvim.homeModules.nixvim ];

    programs.nixvim = {
      enable = true;

      globals.mapleader = " ";

      opts = {
        # UI
        number = true;
        relativenumber = true;
        cursorline = true;
        signcolumn = "yes";
        wrap = false;
        foldlevelstart = 99;

        # Indentation
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        softtabstop = 2;
        smartindent = true;

        # Search
        ignorecase = true;
        smartcase = true;
        incsearch = true;
        hlsearch = true;

        # Editing
        mouse = "a";
        clipboard = "unnamedplus";
        undofile = true;

        # Scrolling
        scrolloff = 8;
        sidescrolloff = 8;

        # Splits
        splitbelow = true;
        splitright = true;

        # Misc
        termguicolors = true;
        updatetime = 250;
      };

      keymaps = [
        { mode = "n"; key = "<leader>w"; action = "<cmd>write<CR>"; options.desc = "Save file"; }
        { mode = "n"; key = "<leader>q"; action = "<cmd>quit<CR>"; options.desc = "Quit"; }
        { mode = "n"; key = "<leader>h"; action = "<C-w>h"; options.desc = "Focus left split"; }
        { mode = "n"; key = "<leader>j"; action = "<C-w>j"; options.desc = "Focus lower split"; }
        { mode = "n"; key = "<leader>k"; action = "<C-w>k"; options.desc = "Focus upper split"; }
        { mode = "n"; key = "<leader>l"; action = "<C-w>l"; options.desc = "Focus right split"; }
        { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; options.desc = "Clear search highlight"; }
      ];

      # Treesitter
      plugins.treesitter = {
        enable = true;

        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;

        grammarPackages =
          with config.programs.nixvim.plugins.treesitter.package.builtGrammars;
          [
            bash
            c
            cpp
            css
            html
            javascript
            json
            lua
            markdown
            nix
            python
            sql
            toml
            tsx
            typescript
            vim
            vimdoc
            yaml
          ];
      };

      # LSP
      plugins.lsp = {
        enable = true;

        servers.nixd = {
          enable = true;

          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }";
              };

              options = {
                nixos = {
                  expr =
                    "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.navi.options";
                };

                home_manager = {
                  expr =
                    "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.navi.options.home-manager.users.type.getSubOptions []";
                };
              };
            };
          };
        };
      };

      # Completion
      plugins.blink-cmp = {
        enable = true;

        settings = {
          keymap.preset = "default";

          sources.default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];

          signature.enabled = true;
        };
      };

      # Noctalia palette via base16
      extraPlugins = with pkgs.vimPlugins; [
        base16-nvim
      ];

      extraConfigLuaPost = ''
        local ok, matugen = pcall(require, "matugen")
        if ok then
          matugen.setup()
        end
      '';
    };
  };
}
