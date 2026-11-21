{
  # Multi-finger gestures for the touchscreen, without patching niri. lisgd reads the touch device
  # directly from its raw events and runs a niri action when a gesture completes. It isn't enabled
  # at login: niri-flip starts it when the laptop folds into tablet mode, and stops it on unfold, so
  # it never runs in laptop use. The device is the Wacom HID 4840 Finger node (event14). Your user
  # joins the input group to read it without running anything as root.
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
    };
  };
}
