#!/bin/sh

exec <&-

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
foot --server &
waypaper --restore &

while true; do
    /home/temesgen/.local/bin/statusbar
    sleep 30
done &

dwlb -ipc
