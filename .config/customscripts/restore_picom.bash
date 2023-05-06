#!/bin/bash
# Restore Picom to custom config
# Tass Suderman -- February 18, 2023

picom -r 16 -i 0.9 -f -e 0.6 --active-opacity 0.95 --vsync -b --config ~/.config/picom.conf
    

