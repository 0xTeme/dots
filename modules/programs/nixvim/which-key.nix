{
  flake.modules.homeManager.nixvim = {
    # Shows the available keys after <leader> and other prefixes, which is the
    # fastest way to learn the keymaps.
    programs.nixvim.plugins.which-key.enable = true;
  };
}
