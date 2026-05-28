# Load autoconfig
config.load_autoconfig(False)

# Font
c.fonts.default_family = "JetBrainsMono Nerd Font"
c.fonts.default_size = "11pt"

# Dark mode
config.set("colors.webpage.darkmode.enabled", True)

# Start page
c.url.start_pages = ["about:blank"]
c.url.default_page = "about:blank"

# Search engines
c.url.searchengines = {
    "DEFAULT": "https://search.brave.com/search?q={}",
    "g": "https://google.com/search?q={}",
    "yt": "https://youtube.com/search?query={}",
    "gh": "https://github.com/search?q={}",
    "aw": "https://wiki.archlinux.org/?search={}",
}

# Scrolling
c.scrolling.smooth = True
c.scrolling.bar = "never"

# Minimal UI
c.tabs.show = "multiple"
c.tabs.position = "top"
c.tabs.padding = {"bottom": 4, "left": 8, "right": 8, "top": 4}
c.tabs.close_mouse_button = "none"
c.statusbar.show = "in-mode"
c.statusbar.widgets = ["keypress", "url", "scroll", "history", "tabs", "progress"]
c.window.hide_decoration = True

# Privacy
c.content.cookies.accept = "no-3rdparty"
c.content.geolocation = False
c.content.notifications.enabled = False

# Ad blocking
c.content.blocking.enabled = True
c.content.blocking.method = "both"

# Keybinds
config.bind("J", "tab-prev")
config.bind("K", "tab-next")
config.bind("d", "tab-close")
config.bind("D", "tab-close --force")
config.bind("<Ctrl-l>", "cmd-set-text -s :open")
config.bind("M", "hint links spawn foot -e yt-dlp {hint-url}")

# Load wallust colors
import os

colors_file = os.path.expanduser("~/.config/qutebrowser/colors.py")
if os.path.exists(colors_file):
    with open(colors_file) as f:
        exec(f.read())
