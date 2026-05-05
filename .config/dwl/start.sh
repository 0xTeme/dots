#!/bin/sh

# Restore wallpaper
waypaper --restore &

# Start foot server for instant terminal launches
foot --server &

# Feed status to dwlb
while true; do
    BAT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    BAT_STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    VOL=$(pamixer --get-volume 2>/dev/null)
    MUTE=$(pamixer --get-mute 2>/dev/null)
    TIME=$(date '+%a %d %b  %H:%M')

    if [ "$MUTE" = "true" ]; then
        VOL_STR="mute"
    else
        VOL_STR="${VOL}%"
    fi

    if [ "$BAT_STATUS" = "Charging" ]; then
        BAT_STR="⚡${BAT}%"
    else
        BAT_STR="🔋${BAT}%"
    fi

    dwlb -status all "${VOL_STR}  ${BAT_STR}  ${TIME}"
    sleep 30
done &

dwlb -ipc
