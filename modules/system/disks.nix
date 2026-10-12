{
  flake.modules.nixos.disks = { pkgs, ... }: {
    services.udisks2.enable = true;

    # Monthly btrfs scrub on the root filesystem. It reads every block and checks it
    # against its checksums, so problems show up early instead of when a file is read.
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };

    environment.systemPackages = [ pkgs.util-linux ];
  };
}
