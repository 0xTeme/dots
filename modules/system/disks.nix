{
  # Backend for mounting removable media from userspace; udisksctl (its own CLI,
  # which modules/programs/yazi.nix's mount plugin uses) comes bundled with this.
  # D-Bus activated, so no idle cost until something actually asks it to mount
  # something. A logged-in graphical session can mount/unmount its own removable
  # media without extra group membership, that's udisks2's default polkit policy.
  flake.modules.nixos.disks = { pkgs, ... }: {
    services.udisks2.enable = true;

    environment.systemPackages = [ pkgs.util-linux ];
  };
}
