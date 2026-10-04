{
  flake.modules.nixos.locale = {
    time.timeZone = "Africa/Addis_Ababa";
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";

    services.xserver.xkb.layout = "us";
  };
}
