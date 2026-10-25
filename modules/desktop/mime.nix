{
  flake.modules.homeManager.mime = { lib, ... }:
    let
      # Give every listed type the same handler.
      handle = app: types: lib.genAttrs types (_: app);
    in
    {
      xdg.mimeApps = {
        enable = true;

        defaultApplications =
          handle "org.gnome.Nautilus.desktop" [ "inode/directory" ]
          // handle "imv.desktop" [
            "image/png"
            "image/jpeg"
            "image/gif"
            "image/webp"
            "image/bmp"
            "image/avif"
            "image/tiff"
          ]
          // handle "org.pwmt.zathura.desktop" [ "application/pdf" ]
          // handle "mpv.desktop" [
            "video/mp4"
            "video/x-matroska"
            "video/webm"
            "video/quicktime"
            "video/x-msvideo"
            "audio/mpeg"
            "audio/flac"
            "audio/ogg"
            "audio/x-wav"
            "audio/mp4"
          ]
          // handle "librewolf.desktop" [
            "text/html"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ]
          // handle "org.telegram.desktop.desktop" [
            "x-scheme-handler/tg"
            "x-scheme-handler/tonsite"
          ];
      };
    };
}
