{
  flake.modules.homeManager.mpd-mpris = { pkgs, ... }: {
    systemd.user.services.mpdris2 = {
      Unit = {
        Description = "mpDris2 - MPRIS2 support for MPD";
        After = [ "mpd.service" ];
      };
      Service = {
        ExecStart = "${pkgs.mpdris2}/bin/mpDris2";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    xdg.configFile."mpDris2/mpDris2.conf".text = ''
      [Library]
      music_dir = ~/Music
    '';
  };
}
