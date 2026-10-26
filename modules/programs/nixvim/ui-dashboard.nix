{ ... }:
let
  # Rows shared by the image and the NAVI header. Only one of them shows at a time.
  imageRows = 16;

  # Blank rows left under the NAVI header inside that block. A smaller number moves the
  # header down, closer to the list. A larger number moves it up.
  headerBottomGap = 2;

  # A Nerd Font glyph from its hex code. Nix strings don't read \u escapes, but JSON does,
  # so the character is built from a JSON string. The file itself stays plain ASCII.
  icon = hex: builtins.fromJSON ''"\u${hex}"'';

  # letter: the single key shown and bound. label: the text, with its icon. lua: the action.
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
  # Home Manager modules receive pkgs and lib, so the resize step lives here.
  flake.modules.homeManager.nixvim = { pkgs, lib, ... }:
    let
      # The repo default, resized at build time to about twice the on-screen size. The plugin
      # decodes the full image on every placement, so a smaller source redraws faster.
      image = pkgs.runCommand "navi-splash.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
        magick ${./assets/splash.png} -resize 720x720 $out
      '';
    in
    {
      programs.nixvim = {
        plugins.alpha = {
          enable = true;
          settings.layout = [
            { type = "padding"; val = 2; }
            {
              # Image on and the window is tall enough: blank rows, with the image drawn over them.
              # Otherwise: the NAVI header, placed in the same rows. Alpha calls this on every redraw.
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
                (button "e" "${icon "f15b"}  New file" "vim.cmd('enew')")
                (button "f" "${icon "f002"}  Find file" "require('fzf-lua').files()")
                (button "r" "${icon "f1da"}  Recent files" "require('fzf-lua').oldfiles()")
                (button "g" "${icon "f15c"}  Find word" "require('fzf-lua').live_grep()")
                (button "i" "${icon "f03e"}  Toggle image" "NaviToggleImage()")
                (button "q" "${icon "f011"}  Quit" "vim.cmd('qa')")
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

        # One image handle, placed once per change. The image plugin handles windows that cover
        # the dashboard, so this only places the image on theme changes, toggles, a fresh
        # dashboard, and size changes. A dashboard shorter than min_height shows the header.
        extraConfigLuaPost = lib.mkAfter ''
          -- A user image wins over the repo default, so it can be swapped without a rebuild.
          local data_home = vim.env.XDG_DATA_HOME or (vim.env.HOME .. "/.local/share")
          local user_img = data_home .. "/navi/splash.png"
          local img_path = (vim.uv.fs_stat(user_img) and user_img) or "${image}"

          local state_file = vim.fn.stdpath("state") .. "/navi-splash-image"
          local rows = ${toString imageRows}
          local bottom_gap = ${toString headerBottomGap}
          local width = 36
          local min_height = 36

          -- The image this module placed last, as { img, win, buf, x }, or nil.
          local current = nil
          -- Whether the image was wanted at the last check, so a change can redraw alpha once.
          local last_wanted = nil

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

          -- True when the image should show: it's enabled, and the dashboard is tall enough.
          local function image_wanted(win)
            return win ~= nil and enabled() and vim.api.nvim_win_get_height(win) >= min_height
          end

          -- What the image slot shows. Called by alpha on every redraw.
          function NaviSplashRows()
            local out = {}
            for i = 1, rows do out[i] = " " end
            if image_wanted(dashboard()) then
              return out
            end
            local top = rows - #header - bottom_gap
            for i, line in ipairs(header) do
              out[top + i] = line
            end
            return out
          end

          -- Removes every image the plugin has drawn, not just ours.
          local function clear_all()
            local ok, api = pcall(require, "image")
            if ok and api.clear then
              pcall(api.clear)
            end
            if ok and api.get_images then
              for _, img in ipairs(api.get_images()) do
                pcall(function() img:clear() end)
              end
            end
            current = nil
          end

          -- Brings the image in line with the screen. With force, it's cleared and placed again.
          -- Without force, it moves only when the dashboard's column changed. When the image
          -- switches on or off, alpha is redrawn so the header or the blank rows match.
          local function show(force)
            local win, buf = dashboard()
            local wanted = image_wanted(win)

            if last_wanted ~= nil and wanted ~= last_wanted then
              force = true
              pcall(function() require("alpha").redraw() end)
            end
            last_wanted = wanted

            if not wanted then
              clear_all()
              return
            end

            local ok, api = pcall(require, "image")
            if not ok then return end

            local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - width) / 2))

            if not force and current and current.win == win and current.buf == buf then
              if current.x ~= col then
                current.x = col
                pcall(function()
                  current.img:render({ x = col, y = 2, width = width, height = rows })
                end)
              end
              return
            end

            clear_all()
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

          -- Debounced entry point. A burst of calls runs one show, after the last call.
          local timer = vim.uv.new_timer()
          local pending_force = false
          local function schedule(force, delay)
            pending_force = pending_force or force
            timer:stop()
            timer:start(delay or 80, 0, vim.schedule_wrap(function()
              local f = pending_force
              pending_force = false
              show(f)
            end))
          end

          -- Called by the "Toggle image" button. Swaps the image and the header, then redraws.
          function NaviToggleImage()
            save(not enabled())
            clear_all()
            pcall(function() require("alpha").redraw() end)
            schedule(true, 250)
          end

          -- A theme change clears and places once, after alpha has redrawn.
          vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function() schedule(true, 250) end,
          })

          -- The palette reload rewrites matugen.lua and can skip the ColorScheme event.
          local watcher = vim.uv.new_fs_event()
          if watcher then
            watcher:start(vim.fn.stdpath("config") .. "/lua", {}, function(err, filename)
              if err or filename ~= "matugen.lua" then return end
              vim.schedule(function() schedule(true, 250) end)
            end)
          end

          -- A fresh dashboard gets one placement.
          vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
              if vim.bo[args.buf].filetype == "alpha" then schedule(true, 250) end
            end,
          })

          -- Size changes move the image to its new center, or swap it for the header when the
          -- window drops below min_height. The plugin handles windows that cover the dashboard.
          vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
            callback = function() schedule(false, 80) end,
          })
        '';
      };
    };
}
