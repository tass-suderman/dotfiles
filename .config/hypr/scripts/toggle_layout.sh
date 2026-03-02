#!/bin/sh

LAYOUT=$(hyprctl getoption general:layout | head -n 1 | sed "s/str: //")

if [ "$LAYOUT" = "dwindle" ]; then
	hyprctl keyword general:layout scrolling
elif [ "$LAYOUT" = "scrolling" ]; then
	hyprctl keyword general:layout dwindle
fi


