{
  flake.modules.nixos.keepassxc = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.keepassxc ];
  };
}
