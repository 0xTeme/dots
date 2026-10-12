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
  };
}
