#!/usr/bin/env bash

# check if not enabled
SHOW_BATTERY_WIDGET=$(tmux show-option -gv @tokyo-night-tmux_show_battery_widget 2>/dev/null)
if [ "${SHOW_BATTERY_WIDGET}" != "1" ]; then
    exit 0
fi

# get value from tmux config
BATTERY_NAME=$(tmux show-option -gv @tokyo-night-tmux_battery_name 2>/dev/null) # default 'BAT1'
BATTERY_LOW=$(tmux show-option -gv @tokyo-night-tmux_battery_low_threshold 2>/dev/null) # default 21
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"

DISCHARGING_ICONS=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
CHARGING_ICONS=("󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
NOT_CHARGING_ICON="󰚥"

default_show_battery_percentage=1
default_battery_name="BAT1"
default_battery_low="21"

BATTERY_NAME="${BATTERY_NAME:-$default_battery_name}"
BATTERY_LOW="${BATTERY_LOW:-$default_battery_low}"

# get battery stats
BATTERY_STATUS=$(< /sys/class/power_supply/${BATTERY_NAME}/status)
BATTERY_PERCENTAGE=$(< /sys/class/power_supply/${BATTERY_NAME}/capacity)

# set color and icon based on battery status
case "${BATTERY_STATUS}" in
  "Charging")
    ICONS="#[fg=green]${CHARGING_ICONS[$((BATTERY_PERCENTAGE / 10 - 1))]}"  ;;
  "Discharging")
    ICONS="${DISCHARGING_ICONS[$((BATTERY_PERCENTAGE / 10 - 1))]}"          ;;
  "Not charging")
    ICONS="${NOT_CHARGING_ICON}"   ;;
  "Full")
    ICONS="FULL"    ;;
esac

# set color on battery capacity
if [[ ${BATTERY_PERCENTAGE} -lt ${BATTERY_LOW} ]]; then
  _color="#[fg=red,bg=default,bold]"
else
  _color="#[fg=yellow,bg=default]"
fi

echo "${_color}░ ${ICONS}${RESET}#[bg=default] ${BATTERY_PERCENTAGE}% "
