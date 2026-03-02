#!/bin/sh

LAYOUT=$(hyprctl getoption general:layout | head -n 1 | sed "s/str: //") 
TYPE=$1
DIRECTION=$2

if [ "$LAYOUT" = "dwindle" ]; then
	if [ "$TYPE" = "focus" ]; then
		hyprctl dispatch move$TYPE $DIRECTION
	elif [ "$TYPE" = "window" ]; then
		hyprctl dispatch move$TYPE $DIRECTION
	elif [ "$TYPE" = "special" ]; then
		hyprctl dispatch togglefloating
	fi
elif [ "$LAYOUT" = "scrolling" ]; then
	if [ "$TYPE" = "focus" ]; then
		hyprctl dispatch layoutmsg "focus $DIRECTION"
	elif [ "$TYPE" = "window" ]; then
		# hyprctl dispatch layoutmsg "movewindowto $DIRECTION"
		if [ "$DIRECTION" = "u" ] || [ "$DIRECTION" = "d" ]; then
			hyprctl dispatch layoutmsg "movewindowto $DIRECTION"
		elif [ "$DIRECTION" = "l" ] || [ "$DIRECTION" = "r" ]; then
			hyprctl dispatch layoutmsg "swapcol $DIRECTION"
		fi
	elif [ "$TYPE" = "special" ]; then
		hyprctl dispatch layoutmsg "promote"
	fi
fi
