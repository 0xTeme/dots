{
  # Square corners for GTK 3 and GTK 4 apps. GTK rejects !important, so this is a plain
  # universal rule. Noctalia owns gtk.css, so this module never rewrites it: it writes its
  # own square.css and appends one import line to gtk.css, only if that line is missing.
  flake.modules.homeManager.gtk-square = { lib, ... }:
    let
      css = ''
        * {
          border-radius: 0;
          box-shadow: none;
        }
      '';
    in
    {
      xdg.configFile."gtk-3.0/square.css".text = css;
      xdg.configFile."gtk-4.0/square.css".text = css;

      home.activation.gtkSquareImport = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        import='@import url("square.css");'
        for dir in gtk-3.0 gtk-4.0; do
          file="$HOME/.config/$dir/gtk.css"
          mkdir -p "$HOME/.config/$dir"
          if ! grep -qF 'square.css' "$file" 2>/dev/null; then
            printf '\n%s\n' "$import" >> "$file"
          fi
        done
      '';
    };
}
