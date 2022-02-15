#!/bin/bash
(
flock 200
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

net=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

outputs=$(xrandr --query | grep ' connected' | cut -d' ' -f1)
[ -z "$outputs" ] && outputs='Not Found'

tray_out=$(xrandr --query | grep ' connected primary ' | cut -d' ' -f1)
[ -z "$tray_out" ] && tray_out=$outputs
[ -z "$tray_out" ] && tray_out='Not Found'

export BACKLIGHT=$(ls -1 /sys/class/backlight|head -n 1)
export BATTERY=$(ls -1 /sys/class/power_supply|grep BAT)
export ADAPTER=$(ls -1 /sys/class/power_supply|grep AC)

if type "xrandr"; then
    for m in $outputs; do
        export MONITOR=$m
        export TRAY_POSITION=none
        export DEFAULT_NET_INTERFACE=none
        if [ "$m" = "$tray_out" ] ; then
            TRAY_POSITION=right
            DEFAULT_NET_INTERFACE=$net
        fi
        polybar --reload main </dev/null >/var/tmp/polybar-$m.log 2>&1 200>&- &
        disown
    done
else
    DEFAULT_NET_INTERFACE=$net polybar main &
fi

) 200>/var/tmp/polybar-launch.lock
