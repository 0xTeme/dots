{
  # Thunar: a GTK3 file manager. Phones (MTP) and USB drives show in its sidebar
  # through gvfs, thumbnails come from tumbler, and bulk rename is built in.
  flake.modules.nixos.file-manager = {
    programs.thunar.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;
  };
}
