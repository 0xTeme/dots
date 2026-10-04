{
  flake.modules.nixos.greeter = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.tuigreet ];

    services.greetd = {
      enable = true;

      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --background matrix --cmd niri-session";
        user = "greeter";
      };
    };
  };
}
