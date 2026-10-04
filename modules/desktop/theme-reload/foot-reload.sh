# Push the Noctalia Foot palette to every running terminal with OSC escape sequences.
# Foot cannot re-read its config at runtime, and SIGUSR1/SIGUSR2 only switch between
# the color sections it loaded at startup, so a new wallpaper palette has to be sent
# to the terminals directly (the same mechanism pywal uses).

theme="$HOME/.config/foot/themes/noctalia"
[ -r "$theme" ] || exit 0

declare -A c
while IFS='=' read -r key value; do
  case "$key" in
    "" | "["* | "#"*) continue ;;
  esac
  c[$key]="$value"
done < "$theme"

esc=$'\033'
st="${esc}\\"
osc=""

# Palette entries 0-7 are the regular colors, 8-15 the bright ones.
for i in 0 1 2 3 4 5 6 7; do
  [ -n "${c[regular$i]:-}" ] && osc+="${esc}]4;${i};#${c[regular$i]}${st}"
  [ -n "${c[bright$i]:-}" ] && osc+="${esc}]4;$((i + 8));#${c[bright$i]}${st}"
done

[ -n "${c[foreground]:-}" ] && osc+="${esc}]10;#${c[foreground]}${st}"
[ -n "${c[background]:-}" ] && osc+="${esc}]11;#${c[background]}${st}"

# cursor= holds "<text color> <cursor color>"; OSC 12 sets the cursor color.
if [ -n "${c[cursor]:-}" ]; then
  read -r _ cursor_color <<< "${c[cursor]}"
  [ -n "$cursor_color" ] && osc+="${esc}]12;#${cursor_color}${st}"
fi

[ -n "${c[selection-background]:-}" ] && osc+="${esc}]17;#${c[selection-background]}${st}"
[ -n "${c[selection-foreground]:-}" ] && osc+="${esc}]19;#${c[selection-foreground]}${st}"

for pts in /dev/pts/[0-9]*; do
  if [ -O "$pts" ] && [ -w "$pts" ]; then
    { printf '%s' "$osc" > "$pts"; } 2>/dev/null &
  fi
done
wait
