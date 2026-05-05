#!/bin/sh
waypaper --restore &
WALLPAPER=$(grep "^wallpaper\s*=" ~/.config/waypaper/config.ini | cut -d= -f2 | tr -d ' ' | sed "s|~|$HOME|")
if [ -f "$WALLPAPER" ]; then
    wallust run "$WALLPAPER"
fi
