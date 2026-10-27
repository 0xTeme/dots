{
  # libvirt/KVM for virtual machines, with virt-manager as the GUI. Spice USB redirection
  # lets a USB Wi-Fi adapter be passed into a VM for monitor mode, which the built-in card
  # can't do. e2fsprogs provides chattr, used once to turn copy-on-write off for the VM
  # image folder: sudo chattr +C /var/lib/libvirt/images
  flake.modules.nixos.virtualization = { pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;

    environment.systemPackages = [ pkgs.e2fsprogs ];

    users.users.teme.extraGroups = [ "libvirtd" ];
  };
}
