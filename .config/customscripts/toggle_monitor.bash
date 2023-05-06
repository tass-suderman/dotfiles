#!/bin/bash
#
#Toggle laptop or external monitors
xrandr --output eDP1 --off && xrandr --output DP1-2 --primary --left-of DP1-1 --mode "1920x1080" --output DP1-1 --mode "1920x1080" || xrandr --ouput eDP1 --auto

