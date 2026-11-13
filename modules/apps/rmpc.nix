{ lib, ... }:
{
  flake.modules.homeManager.rmpc = { pkgs, ... }:
    let
      # The colours in this template are placeholders. The sync script swaps each one for the
      # matching Noctalia colour. The tab bar is 2 rows here, down from 3, which removes the gap
      # under the tabs.
      template = ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]
        (
            default_album_art_path: None,
            show_song_table_header: false,
            draw_borders: true,
            browser_column_widths: [20, 38, 42],
            text_color: "#c1c1c1",
            tab_bar: (
                enabled: true,
                active_style: (fg: "#c1c1c1", bg: "#000000", modifiers: "Bold"),
                inactive_style: (fg: "#333333", modifiers: ""),
            ),
            highlighted_item_style: (fg: "#b3c7cc", modifiers: "Bold"),
            current_item_style: (fg: "#000000", bg: "#b3c7cc", modifiers: "Bold"),
            borders_style: (fg: "#333333", modifiers: ""),
            highlight_border_style: (fg: "#b3c7cc"),
            symbols: (song: "󰝚 ", dir: " ", marker: "* ", ellipsis: "..."),
            progress_bar: (
                symbols: ["█", "█", "█"],
                track_style: (fg: "#333333"),
                elapsed_style: (fg: "#b3c7cc"),
                thumb_style: (fg: "#b3c7cc"),
            ),
            scrollbar: (
                symbols: ["", "", "", ""],
                track_style: (fg: "#333333"),
                ends_style: (fg: "#333333"),
                thumb_style: (fg: "#b3c7cc"),
            ),
            song_table_format: [
                (
                    prop: (kind: Property(Title), style: (fg: "#c1c1c1"),
                        highlighted_item_style: (fg: "#000000", modifiers: "Bold"),
                        default: (kind: Property(Filename), style: (fg: "#333333"),)
                    ),
                    width: "70%",
                ),
                (
                    prop: (kind: Property(Album), style: (fg: "#333333"),
                        default: (kind: Text("Unknown Album"), style: (fg: "#333333"))
                    ),
                    width: "30%",
                ),
            ],
            layout: Split(
                direction: Vertical,
                panes: [
                    (
                        size: "2",
                        pane: Pane(Tabs),
                    ),
                    (
                        size: "4",
                        pane: Split(
                            direction: Horizontal,
                            panes: [
                                (
                                    size: "100%",
                                    pane: Split(
                                        direction: Vertical,
                                        panes: [
                                            (
                                                size: "4",
                                                borders: "ALL",
                                                pane: Pane(Header),
                                            ),
                                        ]
                                    )
                                ),
                            ]
                        ),
                    ),
                    (
                        size: "100%",
                        pane: Split(
                            direction: Horizontal,
                            panes: [
                                (
                                    size: "100%",
                                    borders: "NONE",
                                    pane: Pane(TabContent),
                                ),
                            ]
                        ),
                    ),
                    (
                        size: "3",
                        borders: "TOP | BOTTOM",
                        pane: Pane(ProgressBar),
                    ),
                ],
            ),
            header: (
                rows: [
                    (
                        left: [
                            (kind: Property(Status(StateV2(playing_label: " ", paused_label: "❚❚", stopped_label: "❚❚"))), style: (fg: "#b3c7cc", modifiers: "Bold")),
                        ],
                        center: [
                            (kind: Property(Song(Title)), style: (fg: "#c1c1c1", modifiers: "Bold"),
                                default: (kind: Property(Song(Filename)), style: (fg: "#c1c1c1", modifiers: "Bold"))
                            )
                        ],
                        right: [
                            (kind: Text("Vol: "), style: (fg: "#b3c7cc", modifiers: "Bold")),
                            (kind: Property(Status(Volume)), style: (fg: "#b3c7cc", modifiers: "Bold")),
                            (kind: Text("% "), style: (fg: "#b3c7cc", modifiers: "Bold"))
                        ]
                    ),
                    (
                        left: [
                            (kind: Property(Status(Elapsed)), style: (fg: "#c1c1c1")),
                            (kind: Text("/"), style: (fg: "#333333")),
                            (kind: Property(Status(Duration)), style: (fg: "#c1c1c1")),
                        ],
                        center: [
                            (kind: Property(Song(Artist)), style: (fg: "#5f8787", modifiers: "Bold"),
                                default: (kind: Text("Unknown Artist"), style: (fg: "#333333", modifiers: ""))
                            ),
                        ],
                        right: [
                            (
                                kind: Property(Widget(States(
                                    active_style: (fg: "#b3c7cc", modifiers: "Bold"),
                                    separator_style: (fg: "#333333")))
                                ),
                                style: (fg: "#333333")
                            ),
                        ]
                    ),
                ],
            ),
            browser_song_format: [
                (
                    kind: Group([
                        (kind: Property(Track)),
                        (kind: Text(" ")),
                    ])
                ),
                (
                    kind: Group([
                        (kind: Property(Artist)),
                        (kind: Text(" - ")),
                        (kind: Property(Title)),
                    ]),
                    default: (kind: Property(Filename))
                ),
            ],
        )
      '';

      # Writes rmpc's theme from Noctalia's palette. Noctalia writes its palette in several steps,
      # so the script waits a second for the last write to land. It then replaces the theme file
      # only when the colours changed. Every replacement makes rmpc rebuild its interface, which
      # blanks the album art, so an unchanged palette must not touch the file.
      syncTheme = pkgs.writeShellScript "rmpc-sync-theme" ''
        export PATH=${lib.makeBinPath [ pkgs.gnugrep pkgs.gnused pkgs.coreutils ]}:$PATH
        sleep 1
        src="$HOME/.config/gtk-4.0/noctalia.css"
        [ -r "$src" ] || exit 0

        colour() { grep -m1 "@define-color $1 " "$src" | grep -oE '#[0-9a-fA-F]{6}' | head -n1; }
        text=$(colour window_fg_color)
        accent=$(colour accent_color)
        accent_fg=$(colour accent_fg_color)
        dim=$(colour headerbar_bg_color)
        [ -n "$text" ] && [ -n "$accent" ] && [ -n "$accent_fg" ] && [ -n "$dim" ] || exit 0

        out="$HOME/.config/rmpc/themes/theme.ron"
        tmp="$out.tmp"
        mkdir -p "$(dirname "$out")"
        sed -e "s/#c1c1c1/$text/g" -e "s/#b3c7cc/$accent/g" -e "s/#000000/$accent_fg/g" \
            -e "s/#333333/$dim/g" -e "s/#5f8787/$accent/g" "${pkgs.writeText "rmpc-theme.ron.in" template}" > "$tmp"
        if cmp -s "$tmp" "$out"; then
          rm -f "$tmp"
        else
          mv "$tmp" "$out"
        fi
      '';
    in
    {
      home.packages = with pkgs; [
        rmpc
        cava
      ];

      # cache_dir sits on /run/user, a RAM filesystem, so cached covers and metadata don't write to
      # the SSD. album_art is 600 px: a smaller cover decodes faster on each track change.
      xdg.configFile."rmpc/config.ron".text = ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]
        (
            address: "127.0.0.1:6600",
            password: None,
            theme: Some("theme"),
            cache_dir: Some("/run/user/1000/rmpc"),
            on_song_change: None,
            volume_step: 5,
            max_fps: 30,
            scrolloff: 0,
            wrap_navigation: false,
            enable_mouse: true,
            scroll_amount: 1,
            enable_config_hot_reload: true,
            enable_lyrics_hot_reload: false,
            status_update_interval_ms: 1000,
            rewind_to_start_sec: None,
            keep_state_on_song_change: true,
            reflect_changes_to_playlist: false,
            select_current_song_on_change: false,
            ignore_leading_the: false,
            browser_song_sort: [Disc, Track, Artist, Title],
            directories_sort: SortFormat(group_by_type: true, reverse: false),
            auto_open_downloads: true,
            album_art: (
                method: Auto,
                max_size_px: (width: 600, height: 600),
                disabled_protocols: ["http://", "https://"],
                vertical_align: Center,
                horizontal_align: Center,
            ),
            // Matches the fifo output declared in modules/apps/mpd.nix.
            cava: (
                framerate: 30,
                autosens: true,
                sensitivity: 100,
                input: (
                    method: Fifo,
                    source: "/tmp/mpd.fifo",
                    sample_rate: 44100,
                    channels: 2,
                    sample_bits: 16,
                ),
                smoothing: (
                    noise_reduction: 77,
                    monstercat: true,
                    waves: false,
                ),
                eq: []
            ),
            keybinds: (
                global: {
                    "q":          Quit,
                    "?":          ShowHelp,
                    ":":          CommandMode,
                    "oI":         ShowCurrentSongInfo,
                    "oo":         ShowOutputs,
                    "op":         ShowDecoders,
                    "od":         ShowDownloads,
                    "oP":         Partition(),
                    "z":          ToggleRepeat,
                    "x":          ToggleRandom,
                    "c":          ToggleConsume,
                    "v":          ToggleSingle,
                    "p":          TogglePause,
                    "s":          Stop,
                    ">":          NextTrack,
                    "<":          PreviousTrack,
                    "f":          SeekForward,
                    "b":          SeekBack,
                    ".":          VolumeUp,
                    ",":          VolumeDown,
                    "<Tab>":      NextTab,
                    "gt":         NextTab,
                    "<S-Tab>":    PreviousTab,
                    "gT":         PreviousTab,
                    "1":          SwitchToTab("Queue"),
                    "2":          SwitchToTab("Directories"),
                    "3":          SwitchToTab("Artists"),
                    "4":          SwitchToTab("Album Artists"),
                    "5":          SwitchToTab("Albums"),
                    "6":          SwitchToTab("Playlists"),
                    "7":          SwitchToTab("Search"),
                    "<C-u>":      Update,
                    "<C-U>":      Rescan,
                    "R":          AddRandom,
                },
                navigation: {
                    "<C-c>":      Close,
                    "<Esc>":      Close,
                    "<CR>":       Confirm,
                    "k":          Up,
                    "<Up>":       Up,
                    "j":          Down,
                    "<Down>":     Down,
                    "h":          Left,
                    "<Left>":     Left,
                    "l":          Right,
                    "<Right>":    Right,
                    "<C-w>k":     PaneUp,
                    "<C-Up>":     PaneUp,
                    "<C-w>j":     PaneDown,
                    "<C-Down>":   PaneDown,
                    "<C-w>h":     PaneLeft,
                    "<C-Left>":   PaneLeft,
                    "<C-w>l":     PaneRight,
                    "<C-Right>":  PaneRight,
                    "K":          MoveUp,
                    "J":          MoveDown,
                    "<C-u>":      UpHalf,
                    "<C-d>":      DownHalf,
                    "<C-b>":      PageUp,
                    "<PageUp>":   PageUp,
                    "<C-f>":      PageDown,
                    "<PageDown>": PageDown,
                    "gg":         Top,
                    "G":          Bottom,
                    "<Space>":    Select,
                    "<C-Space>":  InvertSelection,
                    "/":          EnterSearch,
                    "n":          NextResult,
                    "N":          PreviousResult,
                    "a":          Add,
                    "A":          AddAll,
                    "D":          Delete,
                    "<C-r>":      Rename,
                    "i":          FocusInput,
                    "oi":         ShowInfo,
                    "<C-z>":      ContextMenu(),
                    "<C-s>s":     Save(kind: Modal(all: false, duplicates_strategy: Ask)),
                    "<C-s>a":     Save(kind: Modal(all: true, duplicates_strategy: Ask)),
                    "r":          Rate(),
                },
                queue: {
                    "d":          Delete,
                    "D":          DeleteAll,
                    "<CR>":       Play,
                    "C":          JumpToCurrent,
                    "X":          Shuffle,
                },
            ),
            search: (
                case_sensitive: false,
                ignore_diacritics: false,
                search_button: false,
                mode: Contains,
                tags: [
                    (value: "any",         label: "Any Tag"),
                    (value: "artist",      label: "Artist"),
                    (value: "album",       label: "Album"),
                    (value: "albumartist", label: "Album Artist"),
                    (value: "title",       label: "Title"),
                    (value: "filename",    label: "Filename"),
                    (value: "genre",       label: "Genre"),
                ],
            ),
            artists: (
                album_display_mode: SplitByDate,
                album_sort_by: Date,
                album_date_tags: [Date],
            ),
            tabs: [
                (
                    name: "Queue",
                    pane: Split(
                        direction: Vertical,
                        panes: [
                            (
                                size: "100%",
                                pane: Split(
                                    direction: Horizontal,
                                    panes: [
                                        (
                                            size: "40%",
                                            borders: "ALL",
                                            border_symbols: Plain,
                                            pane: Pane(AlbumArt)
                                        ),
                                        (
                                            size: "65%",
                                            pane: Split(
                                                direction: Vertical,
                                                panes: [
                                                    (
                                                        size: "3",
                                                        borders: "ALL",
                                                        border_symbols: Plain,
                                                        pane: Split(
                                                            direction: Horizontal,
                                                            panes: [
                                                                (size: "1", pane: Pane(Empty())),
                                                                (size: "100%", pane: Pane(QueueHeader())),
                                                            ]
                                                        )
                                                    ),
                                                    (
                                                        size: "100%",
                                                        borders: "LEFT | RIGHT | BOTTOM",
                                                        border_symbols: Plain,
                                                        pane: Pane(Queue)
                                                    ),
                                                ],
                                            )
                                        ),
                                    ],
                                ),
                            ),
                            (
                                size: "6",
                                borders: "ALL",
                                border_symbols: Plain,
                                border_title: [(kind: Text(" Visualizer "))],
                                pane: Pane(Cava)
                            ),
                        ],
                    ),
                ),
                (
                    name: "Directories",
                    borders: "ALL",
                    border_symbols: Plain,
                    pane: Split(size: "100%", direction: Vertical, panes: [(pane: Pane(Directories), size: "100%", borders: "ALL", border_symbols: Plain)])
                ),
                (
                    name: "Artists",
                    borders: "ALL",
                    border_symbols: Plain,
                    pane: Split(size: "100%", direction: Vertical, panes: [(pane: Pane(Artists), size: "100%", borders: "ALL", border_symbols: Plain)])
                ),
                (
                    name: "Album Artists",
                    borders: "ALL",
                    border_symbols: Plain,
                    pane: Split(size: "100%", direction: Vertical, panes: [(pane: Pane(AlbumArtists), size: "100%", borders: "ALL", border_symbols: Plain)])
                ),
                (
                    name: "Albums",
                    borders: "ALL",
                    border_symbols: Plain,
                    pane: Split(size: "100%", direction: Vertical, panes: [(pane: Pane(Albums), size: "100%", borders: "ALL", border_symbols: Plain)])
                ),
                (
                    name: "Playlists",
                    borders: "ALL",
                    border_symbols: Plain,
                    pane: Split(size: "100%", direction: Vertical, panes: [(pane: Pane(Playlists), size: "100%", borders: "ALL", border_symbols: Plain)])
                ),
                (
                    name: "Search",
                    borders: "ALL",
                    border_symbols: Plain,
                    pane: Split(size: "100%", direction: Vertical, panes: [(pane: Pane(Search), size: "100%", borders: "ALL", border_symbols: Plain)])
                ),
            ],
        )
      '';

      # Keeps rmpc's theme in step with Noctalia: runs at login, and when Noctalia rewrites its palette.
      systemd.user.paths.rmpc-theme = {
        Unit.Description = "Watch Noctalia's palette for rmpc";
        Path.PathChanged = "%h/.config/gtk-4.0/noctalia.css";
        Install.WantedBy = [ "default.target" ];
      };

      systemd.user.services.rmpc-theme = {
        Unit.Description = "Write rmpc's theme from Noctalia's palette";
        Install.WantedBy = [ "default.target" ];
        Service = {
          Type = "oneshot";
          ExecStart = "${syncTheme}";
        };
      };
    };
}
