{
  # Multi-finger gestures for the touchscreen, without patching niri. lisgd reads the touch device
  # directly from its raw events and runs a niri action when a gesture completes. It only blocks
  # on the device between touches, so it costs almost nothing while idle. The device is the
  # Wacom HID 4840 Finger node (event14); the stylus on the same panel is event13 and is not used.
  # Your user joins the input group to read the device without running anything as root. The
  # service is tied to niri, so it starts and stops with the session.
  flake.modules.nixos.touch-gestures = { pkgs, ... }: {
    users.users.teme.extraGroups = [ "input" ];

    environment.systemPackages = [ pkgs.lisgd ];
  };

  flake.modules.homeManager.touch-gestures = { pkgs, ... }: {
    systemd.user.services.lisgd = {
      Unit = {
        Description = "Touchscreen gestures for niri";
        PartOf = [ "niri.service" ];
        After = [ "niri.service" ];
      };
      Service = {
        ExecStart = ''
          ${pkgs.lisgd}/bin/lisgd -d /dev/input/event14 -t 10 -T 5 \
            -g "3,RL,*,*,R,niri msg action focus-column-right" \
            -g "3,LR,*,*,R,niri msg action focus-column-left" \
            -g "3,DU,*,*,R,niri msg action focus-workspace-down" \
            -g "3,UD,*,*,R,niri msg action focus-workspace-up" \
            -g "4,DU,*,*,R,niri msg action toggle-overview"
        '';
        Restart = "on-failure";
      };
      Install.WantedBy = [ "niri.service" ];
    };
  };
}
