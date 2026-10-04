{
  flake.modules.nixos.docker = {
    virtualisation.docker = {
      enable = true;
      # Socket activation is already NixOS's default; this just stops dockerd
      # from also starting eagerly at boot. First `docker` command wakes it.
      enableOnBoot = false;
    };

    users.users.teme.extraGroups = [ "docker" ];
  };
}
