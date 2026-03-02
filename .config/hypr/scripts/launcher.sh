#!/bin/sh

LAUNCHER=$1
TYPE=$2

if [ "$LAUNCHER" = "rofi" ]; then
	if [ "$TYPE" = "clipboard" ]; then
		clipcat-menu
	fi
	if [ "$TYPE" = "drun" ]; then
		rofi -modi drun -show drun -show-icons
	fi
	if [ "$TYPE" = "emoji" ]; then
		rofi -modi emoji -show emoji -show-icons
	fi
	if [ "$TYPE" = "browser" ]; then
		rofi -modi recursivebrowser -show recursivebrowser -show-icons
	fi
	if [ "$TYPE" = "power" ]; then
		rofi -show p -modi p:rofi-power-menu
	fi
	if [ "$TYPE" = "run" ]; then
		rofi -modi run -show run
	fi
	if [ "$TYPE" = "window" ]; then
		rofi -modi window -show window -show-icons
	fi
fi
