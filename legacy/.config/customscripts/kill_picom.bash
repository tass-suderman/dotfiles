#!/bin/bash
# Kills Picom instances
# Tass Suderman -- February 18, 2023


kill -9 $(ps aux | grep picom | awk '{print $2,$11}' | grep picom | awk '{print $1}')
