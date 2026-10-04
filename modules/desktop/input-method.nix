{
  flake.modules.nixos.input-method = { pkgs, ... }: {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        waylandFrontend = true;

        addons = with pkgs; [
          fcitx5-m17n
          fcitx5-gtk
        ];

        settings = {
          inputMethod = {
            GroupOrder."0" = "Default";

            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "m17n_am_sera";
            };

            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "m17n_am_sera";
          };

          globalOptions = {
            Hotkey = {
              EnumerateWithTriggerKeys = "True";
            };

            "Hotkey/TriggerKeys"."0" = "Control+space";
          };
        };

        ignoreUserConfig = true;
      };
    };
  };
}
