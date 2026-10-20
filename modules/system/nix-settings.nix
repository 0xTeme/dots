{
  flake.modules.nixos.nix-settings = {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];

      # Noctalia's cachix branch ships prebuilt binaries here. Without this, every
      # Noctalia update compiles from source, confirmed the hard way, a 56-minute
      # build for the 5.3.0 bump that should have been a download.
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
}
