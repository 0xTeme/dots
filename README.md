# System Configuration Notes

## /etc/tlp.conf changes
- CPU_SCALING_GOVERNOR_ON_BAT=powersave
- CPU_ENERGY_PERF_POLICY_ON_BAT=power
- PLATFORM_PROFILE_ON_BAT=low-power
- CPU_MAX_PERF_ON_BAT=80
- DEVICES_TO_DISABLE_ON_STARTUP="bluetooth nfc"

## /boot/loader/entries/arch.conf
options root=UUID=9ffadd7e-f0b6-4a2a-baf2-c203d8b441c7 rw quiet loglevel=3 i915.enable_fbc=1 i915.enable_psr=1 nmi_watchdog=0 vm.dirty_writeback_centisecs=6000

## systemd masked units
- systemd-rfkill.service
- systemd-rfkill.socket
