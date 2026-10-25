{
  # Bottom bar: mode and branch on the left, file, diagnostics and filetype in the middle,
  # position on the right. Square separators, and colors come from the active palette.
  flake.modules.homeManager.nixvim.programs.nixvim.plugins.lualine = {
    enable = true;
    settings = {
      options = {
        theme = "auto";
        globalstatus = true;
        component_separators = {
          left = "│";
          right = "│";
        };
        section_separators = {
          left = "";
          right = "";
        };
      };
      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [ "branch" "diff" ];
        lualine_c = [ "filename" ];
        lualine_x = [ "diagnostics" "filetype" ];
        lualine_y = [ "progress" ];
        lualine_z = [ "location" ];
      };
    };
  };
}
