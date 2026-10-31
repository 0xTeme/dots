# navi

NixOS flake, dendritic pattern (flake-parts + import-tree). Niri + Noctalia v5
+ Home Manager + Nixvim.

## Structure

Every `.nix` file under `modules/` is a flake-parts module, auto-imported.
A file declares a feature under `flake.modules.nixos.<name>` or
`flake.modules.homeManager.<name>`. Nothing applies until the feature name is
listed in `modules/hosts/navi.nix`.

Add something: new file, declare the feature, add its name to `navi.nix`, rebuild.
Remove something: delete the line in `navi.nix`.

Files must be tracked by git, or import-tree won't see them.

    modules/
      flake-parts.nix
      hosts/       navi.nix (feature list), navi-hardware.nix
      system/      boot, nix-settings, network, locale, fonts, audio, power, security,
                   base-packages, disks (monthly btrfs scrub), docker (idle until first use),
                   nix-ld
      users/       teme.nix
      desktop/     niri/, xwayland, greeter, noctalia, input-method, mime, theme-reload,
                   cursor, qt, gtk-dark, gtk-reload, gtk-square, file-manager (Nautilus)
      apps/        foot, librewolf, telegram, libreoffice, imv, zathura, mpv, glow,
                   mpd, mpd-mpris, rmpc, screen-recorder, btop, keepassxc, pavucontrol,
                   typing, localsend, udiskie, virtualization (libvirt, virt-manager)
      security/    security-tools (catalog, nothing enabled by default), wireless-audit,
                   recon
      programs/    bash (prompt, eza, zoxide, bat), fzf, fastfetch, yazi, xdg-dirs, git,
                   agy, opencode, nh, nixvim/ (editor, IDE layer, dashboard with splash
                   image, lualine, file tree)

## Rebuild

    cd ~/dots
    git add -A
    nh os build .        # builds and shows the package diff before anything is applied
    nh os switch .       # applies it
    git commit -m "..."

## Conventions

- Nix/Home Manager own configuration; Noctalia owns the color palette; apps consume it.
  Nothing Nix-generated is left for Noctalia to overwrite.
- Foot, Yazi and Neovim don't reload their own theme; systemd path units watch
  Noctalia's generated files and push the update live.
- `niri/config.kdl` includes `base.kdl` (mostly stock) and layers overrides on
  top, plus an optional `toggles.kdl` written at runtime.
- Some files under `desktop/` export both a NixOS and a Home Manager feature
  from the same `.nix` file (`niri/niri.nix`, `theme-reload/theme-reload.nix`).
  The NixOS side is listed in `navi.nix`; the HM side is imported in `teme.nix`.
- A package lives with what it fundamentally is (`xwayland-satellite` under
  `desktop/`), not with whatever first needed it, even if today only one thing
  actually uses it.
- Security tooling lives under `security/`, not `apps/`: `security-tools.nix`
  is a browsing catalog (nothing active by default), `wireless-audit.nix` holds
  tools actually adopted.
- LibreWolf's extensions (Dark Reader, Stylus) are force-installed via policies
  through Home Manager's Firefox module with its package swapped to LibreWolf,
  not `programs.librewolf` directly (open upstream bug, see commit history).
  `userChrome.css` in its real profile is hand-written, not Nix-managed, to
  avoid the profile-declaration system creating a second profile by accident.
- Every change here is applied as a full-file replacement, not a patch.

## Splash image

The Neovim dashboard image is `modules/programs/nixvim/assets/splash.png`. Build time resizes a copy for it.

To use a different picture without rebuilding, put it at `~/.local/share/navi/splash.png` and reopen Neovim. Delete that file to return to the repo default. The override is drawn at its original size, so use a picture of about the same proportions.
