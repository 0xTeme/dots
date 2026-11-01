{
  flake.modules.homeManager.fzf = {
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    # Noctalia's fzf template writes its colours to this file, but fzf only reads
    # FZF_DEFAULT_OPTS from the shell's environment. Sourcing the file applies the palette
    # to every new shell. The guard means nothing breaks before the template has rendered.
    programs.bash.initExtra = ''
      __navi_fzf_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/fzf/themes/noctalia.sh"
      [ -f "$__navi_fzf_theme" ] && . "$__navi_fzf_theme"
      unset __navi_fzf_theme
    '';
  };
}
