{
  # LocalSend with a Nautilus right-click entry. The extension is a short Python file that
  # runs only when a context menu opens on files. nautilus-python loads it when Nautilus
  # starts, so the entry appears after Nautilus restarts. The wiring follows nixpkgs'
  # programs.nautilus-open-any-terminal module: the extension directory variable and the
  # pathsToLink entry.
  flake.modules.nixos.localsend = { pkgs, ... }:
    let
      extension = pkgs.writeTextDir "share/nautilus-python/extensions/localsend_send.py" ''
        import shutil
        import subprocess

        from gi.repository import GObject, Nautilus


        class LocalSendSend(GObject.GObject, Nautilus.MenuProvider):
            def get_file_items(self, *args):
                files = args[-1]
                paths = []
                for f in files:
                    path = f.get_location().get_path()
                    if path is None:
                        return []
                    paths.append(path)
                if not paths:
                    return []

                if len(paths) == 1:
                    label = "Send with LocalSend"
                else:
                    label = f"Send {len(paths)} files with LocalSend"

                item = Nautilus.MenuItem(name="LocalSend::send_files", label=label)
                item.connect("activate", self._send, paths)
                return [item]

            def _send(self, _item, paths):
                binary = shutil.which("localsend") or shutil.which("localsend_app")
                if binary:
                    subprocess.Popen([binary, *paths])
      '';
    in
    {
      environment.systemPackages = [
        pkgs.localsend
        pkgs.nautilus-python
        extension
      ];

      environment.pathsToLink = [ "/share/nautilus-python/extensions" ];

      # Lets nautilus-python find its loader. Takes effect at the next login.
      environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR =
        "${pkgs.nautilus-python}/lib/nautilus/extensions-4";

      # LocalSend discovery and transfers use port 53317, over both TCP and UDP.
      networking.firewall = {
        allowedTCPPorts = [ 53317 ];
        allowedUDPPorts = [ 53317 ];
      };
    };
}
