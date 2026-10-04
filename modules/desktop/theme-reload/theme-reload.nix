{
  # Noctalia rewrites theme files when the wallpaper or mode changes. Nix owns the
  # reload wiring: a systemd path unit notices the file change and tells the running
  # app. No Noctalia hooks are involved, so there is no render order to get wrong.
  flake.modules.homeManager.theme-reload = { config, lib, pkgs, ... }:
    let
      sleep = lib.getExe' pkgs.coreutils "sleep";
      pkill = lib.getExe' pkgs.procps "pkill";
      ya = lib.getExe' config.programs.yazi.package "ya";

      yaziReload = pkgs.writeShellScript "yazi-theme-reload" ''
        # flavor.toml and tmtheme.xml are rewritten a moment apart.
        ${sleep} 0.5
        ${ya} emit-to 0 app:theme || true
      '';

      footReload = pkgs.writeShellScript "foot-theme-reload" (builtins.readFile ./foot-reload.sh);

      # Same gap Foot had: Noctalia regenerates the file but never signals a running
      # instance. base16-nvim's own reload handler already answers to SIGUSR1
      # (confirmed by hand: pkill -SIGUSR1 nvim works).
      nvimReload = pkgs.writeShellScript "nvim-theme-reload" ''
        ${pkill} -SIGUSR1 nvim || true
      '';
    in
    {
      systemd.user = {
        paths = {
          yazi-theme-reload = {
            Unit.Description = "Watch Noctalia's Yazi flavor";
            Path.PathChanged = [
              "%h/.config/yazi/flavors/noctalia.yazi/flavor.toml"
              "%h/.config/yazi/flavors/noctalia.yazi/tmtheme.xml"
            ];
            Install.WantedBy = [ "default.target" ];
          };

          foot-theme-reload = {
            Unit.Description = "Watch Noctalia's Foot theme";
            Path.PathChanged = "%h/.config/foot/themes/noctalia";
            Install.WantedBy = [ "default.target" ];
          };

          nvim-theme-reload = {
            Unit.Description = "Watch Noctalia's Neovim palette";
            Path.PathChanged = "%h/.config/nvim/lua/matugen.lua";
            Install.WantedBy = [ "default.target" ];
          };
        };

        services = {
          yazi-theme-reload = {
            Unit.Description = "Reload the theme of running Yazi instances";
            Service = {
              Type = "oneshot";
              ExecStart = "${yaziReload}";
            };
          };

          foot-theme-reload = {
            Unit.Description = "Push the Noctalia palette to running Foot terminals";
            Service = {
              Type = "oneshot";
              TimeoutStartSec = 10;
              ExecStart = "${footReload}";
            };
          };

          nvim-theme-reload = {
            Unit.Description = "Signal running Neovim instances to reload their palette";
            Service = {
              Type = "oneshot";
              ExecStart = "${nvimReload}";
            };
          };
        };
      };
    };
}
