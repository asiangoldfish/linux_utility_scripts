#/usr/bin/bash

IFS=': ' read -ra numbers <<< "$(xrandr --listactivemonitors | grep 'Monitors')"
if [[ "${numbers[1]}" > 1 ]]; then xrandr --output eDP --off; fi
