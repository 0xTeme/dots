{
  # The default editor is one setting spread over two places, so both live in this file.

  flake.modules.homeManager.nixvim = {
    # Login and graphical sessions. Applies from the next login.
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  flake.modules.homeManager.bash = {
    # NixOS's /etc/bashrc can export its own EDITOR=nano into interactive shells, and
    # .bashrc runs after it. This applies to every new shell immediately.
    programs.bash.initExtra = ''
      export EDITOR=nvim VISUAL=nvim
    '';
  };
}
