#!/bin/bash
# Toggle Picom Setting
# Tass Suderman -- February 18, 2023

#OPTIMIZATION TO MAKE LATER -- Have the kill script return true or false, whether or not it killed picom. if false, call the restore script with a one liner:
$(bash ~/.config/customscripts/kill_picom.bash || bash ~/.config/customscripts/restore_picom.bash) &> /dev/null

#if [[ $(ps aux | grep picom | awk '{print $11}' | grep picom) ]]
#then
#    bash ~/.config/customscripts/kill_picom.bash
#else
#    bash ~/.config/customscripts/restore_picom.bash
#fi
