{
  flake.modules.nixos.greeter = { pkgs, ... }: {
    services.greetd = {
      enable = true;

      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --background matrix --cmd niri-session";
        user = "greeter";
      };
    };
  };
}
