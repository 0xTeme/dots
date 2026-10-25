{ config, inputs, ... }:
let
  # One binding shared by the system user and the Home Manager user.
  user = "teme";
in
{
  flake.modules.nixos.teme = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.bash;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      # Move a pre-existing real file aside instead of aborting activation.
      backupFileExtension = "hm-bak";

      users.${user} = {
        imports = with config.flake.modules.homeManager; [
          niri
          cursor
          nixvim
          bash
          fzf
          fastfetch
          foot
          git
          yazi
          xdg-dirs
          imv
          zathura
          mpv
          glow
          mime
          mpd
          mpd-mpris
          rmpc
          btop
          typing
          theme-reload
          gtk-reload
          librewolf
          opencode
          agy
          nh
          udiskie
          qt
        ];

        home.stateVersion = "26.05";
        programs.home-manager.enable = true;
      };
    };
  };
}
