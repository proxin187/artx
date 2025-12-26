#!/bin/bash

case $BUTTON in
    4) amixer sset Master 5%+ && pkill -USR1 -f dwm-statusbar ;;
    5) amixer sset Master 5%- && pkill -USR1 -f dwm-statusbar ;;
    1) amixer sset Master toggle && pkill -USR1 -f dwm-statusbar ;;
esac


