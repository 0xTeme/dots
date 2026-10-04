{
  # Lets generic, non-Nix-packaged dynamically-linked binaries (like agy,
  # Antigravity's own closed-source installer) find their shared libraries.
  # NixOS doesn't use standard filesystem paths for this by default, nix-ld
  # provides a stub loader that redirects to the real ones in the Nix store.
  flake.modules.nixos.nix-ld = {
    programs.nix-ld.enable = true;
  };
}
