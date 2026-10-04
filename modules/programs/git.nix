{
  flake.modules.homeManager.git =
    let
      # Swap for GitHub's noreply address if you do not want your real one in a public repo.
      email = "205241428+0xTeme@users.noreply.github.com";
    in
    {
      programs.git = {
        enable = true;

        settings = {
          user = {
            name = "0xTeme";
            inherit email;
          };

          init.defaultBranch = "main";
        };
      };
    };
}
