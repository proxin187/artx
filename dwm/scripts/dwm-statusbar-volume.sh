#!/bin/bash

case $BUTTON in
    4) pamixer -i 5 && pkill -USR1 -f dwm-statusbar ;;
    5) pamixer -d 5 && pkill -USR1 -f dwm-statusbar ;;
    1) pamixer -t && pkill -USR1 -f dwm-statusbar ;;
esac


