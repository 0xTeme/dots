# Hardware and disk layout of the Dell Latitude 7390 2-in-1.
# Derived from nixos-generate-config, but every mount is defined exactly once.
let
  # The single Btrfs partition (label NIXOS) holding root, home, nix and swap.
  nixosPartition = "/dev/disk/by-uuid/c51ba01e-e849-4b22-9791-940864d44f73";

  btrfsSubvolume = subvol: extraOptions: {
    device = nixosPartition;
    fsType = "btrfs";
    options = [ "subvol=${subvol}" ] ++ extraOptions;
  };
in
{
  flake.modules.nixos.navi-hardware = { modulesPath, pkgs, ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
    boot.kernelModules = [ "kvm-intel" ];

    fileSystems = {
      "/" = btrfsSubvolume "root" [ "compress=zstd" ];
      "/home" = btrfsSubvolume "home" [ "compress=zstd" ];
      "/nix" = btrfsSubvolume "nix" [ "compress=zstd" "noatime" ];
      "/swap" = btrfsSubvolume "swap" [ "noatime" ];

      "/boot" = {
        device = "/dev/disk/by-uuid/10D5-8D0F";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };
    };

    zramSwap = {
      enable = true;
      priority = 5;
    };

    swapDevices = [{
      device = "/swap/swapfile";
      size = 8 * 1024;
      priority = null;
    }];

    nixpkgs.hostPlatform = "x86_64-linux";

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;

      bluetooth = {
        enable = true;
        # Radio stays off at boot. Noctalia's toggle flips the BlueZ adapter's
        # Powered property live and independently of this, so it can still be
        # turned on any time from the bar without a reboot.
        powerOnBoot = false;
      };

      # Intel UHD 620 (Kaby Lake R): VA-API decoding through the iHD driver.
      graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-media-driver ];
      };
    };
  };
}
