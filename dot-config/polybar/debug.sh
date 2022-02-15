#!/bin/bash
(
flock 200
killall -q polybar # Terminate already running bar instances
# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

# 自动选择合适的网络接口
# https://github.com/polybar/polybar/issues/339#issuecomment-447674287
net=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

outputs=$(xrandr --query | grep ' connected' | cut -d' ' -f1)
[ -z "$outputs" ] && outputs='Not Found'
printf "[INFO] polybar outputs: \n$outputs\n"

tray_out=$(xrandr --query | grep ' connected primary ' | cut -d' ' -f1)
[ -z "$tray_out" ] && tray_out=$outputs
[ -z "$tray_out" ] && tray_out='Not Found'
printf "[INFO] tray outputs: \n$tray_out\n"

# Launch Polybar, using default config location ~/.config/polybar/config
# polybar main &

export BACKLIGHT=$(ls -1 /sys/class/backlight|head -n 1)
export BATTERY=$(ls -1 /sys/class/power_supply|grep BAT)
export ADAPTER=$(ls -1 /sys/class/power_supply|grep AC)

# Auto configure multiple monitors https://github.com/polybar/polybar/issues/763
if type "xrandr"; then
    for m in $outputs; do
        export MONITOR=$m
        export TRAY_POSITION=none
        export DEFAULT_NET_INTERFACE=none
        if [ "$m" = "$tray_out" ] ; then
            TRAY_POSITION=right
            DEFAULT_NET_INTERFACE=$net
        fi
        echo "[INFO] $MONITOR show net interface: $DEFAULT_NET_INTERFACE"
        polybar --reload main </dev/null >/var/tmp/polybar-$m.log 2>&1 200>&-
    done
else
    # DEFAULT_NET_INTERFACE=$net polybar --reload main &
    DEFAULT_NET_INTERFACE=$net polybar main
fi

# DEFAULT_NET_INTERFACE=$net TRAY_POSITION=right polybar --reload main </dev/null >/var/tmp/polybar-$m.log 2>&1 200>&- &

printf "[INFO] launch polybar...\n"
) 200>/var/tmp/polybar-launch.lock
