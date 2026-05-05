# Wallust generated colors
bg0 = "#{background.strip}"
bg1 = "#{color0.strip}"
bg2 = "#{color1.strip}"
fg  = "#{foreground.strip}"
ac  = "#{color4.strip}"
red = "#{color1.strip}"

# Completion
c.colors.completion.fg = fg
c.colors.completion.odd.bg = bg1
c.colors.completion.even.bg = bg0
c.colors.completion.category.fg = ac
c.colors.completion.category.bg = bg0
c.colors.completion.category.border.top = bg0
c.colors.completion.category.border.bottom = bg0
c.colors.completion.item.selected.fg = bg0
c.colors.completion.item.selected.bg = ac
c.colors.completion.item.selected.border.top = ac
c.colors.completion.item.selected.border.bottom = ac
c.colors.completion.match.fg = ac
c.colors.completion.scrollbar.fg = fg
c.colors.completion.scrollbar.bg = bg0

# Downloads
c.colors.downloads.bar.bg = bg0
c.colors.downloads.start.fg = bg0
c.colors.downloads.start.bg = ac
c.colors.downloads.stop.fg = bg0
c.colors.downloads.stop.bg = fg
c.colors.downloads.error.fg = red

# Hints
c.colors.hints.fg = bg0
c.colors.hints.bg = ac
c.colors.hints.match.fg = fg

# Keyhint
c.colors.keyhint.fg = fg
c.colors.keyhint.suffix.fg = ac
c.colors.keyhint.bg = bg0

# Messages
c.colors.messages.error.fg = bg0
c.colors.messages.error.bg = red
c.colors.messages.error.border = red
c.colors.messages.warning.fg = bg0
c.colors.messages.warning.bg = ac
c.colors.messages.warning.border = ac
c.colors.messages.info.fg = fg
c.colors.messages.info.bg = bg0

# Statusbar
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.normal.bg = bg0
c.colors.statusbar.insert.fg = bg0
c.colors.statusbar.insert.bg = ac
c.colors.statusbar.passthrough.fg = bg0
c.colors.statusbar.passthrough.bg = fg
c.colors.statusbar.command.fg = fg
c.colors.statusbar.command.bg = bg0
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.success.http.fg = fg
c.colors.statusbar.url.success.https.fg = ac
c.colors.statusbar.url.error.fg = red
c.colors.statusbar.url.warn.fg = ac
c.colors.statusbar.url.hover.fg = fg

# Tabs
c.colors.tabs.bar.bg = bg0
c.colors.tabs.odd.fg = fg
c.colors.tabs.odd.bg = bg1
c.colors.tabs.even.fg = fg
c.colors.tabs.even.bg = bg0
c.colors.tabs.selected.odd.fg = bg0
c.colors.tabs.selected.odd.bg = ac
c.colors.tabs.selected.even.fg = bg0
c.colors.tabs.selected.even.bg = ac
