#!/bin/sh

LAUNCHER=$1
TYPE=$2

if [ "$LAUNCHER" = "quickshell" ]; then
	if [ "$TYPE" = "clipboard" ]; then
		# Clipboard is handled by clipcat-menu (external)
		clipcat-menu
	else
		quickshell ipc call launcher open "$TYPE"
	fi
fi
