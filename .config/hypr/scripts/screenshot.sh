#!/bin/sh

format=png
path="$HOME/Pictures/Screenshots"
if [ !  -d "$path" ]; then
	mkdir -p $path
fi
filename="Screenshot $(date '+%Y-%m-%d %H%M%S')"

hyprpicker -rz &
sleep 0.2 # wait on hyprpicker
#bounds=$(slurp -d)
if [ $format=="jpg" ]; then
	grim -t jpeg -q 50 "$path/$filename.$format"
else
	grim -t png -q 100 "$path/$filename.$format"
fi
#wl-copy < "$path/$filename.$format"
killall hyprpicker
