{
  flake.modules.nixos.boot = {
    boot.loader = {
      systemd-boot = {
        enable = true;
        # The 1 GiB ESP is shared with Windows, so keep only the newest generations on it.
        configurationLimit = 10;
        # Memory tester in the boot menu, for diagnosing RAM faults.
        memtest86.enable = true;
      };

      efi.canTouchEfiVariables = true;

      # Menu wait in seconds. Press any key during boot to open it.
      timeout = 2;
    };

    # Keep the SATA link at maximum performance (policy 1 = max_performance). Link power
    # saving was active on the SSD's port, and we're testing whether it contributes to the
    # Btrfs checksum errors. This is a test, not a confirmed fix.
    boot.kernelParams = [ "ahci.mobile_lpm_policy=1" ];
  };
}
