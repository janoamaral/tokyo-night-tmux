#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

# check if not enabled
SHOW_BATTERY_WIDGET=$(tmux show-option -gv @tokyo-night-tmux_show_battery_widget 2>/dev/null)
if [ "${SHOW_BATTERY_WIDGET}" != "1" ]; then
  exit 0
fi

# get value from tmux config
BATTERY_NAME=$(tmux show-option -gv @tokyo-night-tmux_battery_name 2>/dev/null)         # default 'BAT1'
BATTERY_LOW=$(tmux show-option -gv @tokyo-night-tmux_battery_low_threshold 2>/dev/null) # default 21
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"

DISCHARGING_ICONS=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
CHARGING_ICONS=("󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
NOT_CHARGING_ICON="󰚥"
NO_BATTERY_ICON="󱉝"

default_show_battery_percentage=1
default_battery_low="21"
if [[ "$(uname)" == "Darwin" ]]; then
  default_battery_name="InternalBattery-0"
else
  default_battery_name="BAT1"
fi

BATTERY_NAME="${BATTERY_NAME:-$default_battery_name}"
BATTERY_LOW="${BATTERY_LOW:-$default_battery_low}"

# get battery stats
if [[ "$(uname)" == "Darwin" ]]; then
  pmstat=$(pmset -g batt | grep $BATTERY_NAME)
  BATTERY_STATUS=$(echo $pmstat | awk '{print $4}' | sed 's/[^a-z]*//g')
  BATTERY_PERCENTAGE=$(echo $pmstat | awk '{print $3}' | sed 's/[^0-9]*//g')
else
  BATTERY_STATUS=$(</sys/class/power_supply/${BATTERY_NAME}/status)
  BATTERY_PERCENTAGE=$(</sys/class/power_supply/${BATTERY_NAME}/capacity)
fi

# set color and icon based on battery status
case "${BATTERY_STATUS}" in
"Charging" | "charging")
  ICONS="${CHARGING_ICONS[$((BATTERY_PERCENTAGE / 10 - 1))]}"
  ;;
"Discharging" | "discharging")
  ICONS="${DISCHARGING_ICONS[$((BATTERY_PERCENTAGE / 10 - 1))]}"
  ;;
"Not charging" | "AC")
  ICONS="${NOT_CHARGING_ICON}"
  ;;
"Full" | "charged")
  ICONS="${NOT_CHARGING_ICON}"
  ;;
*)
  ICONS="${NO_BATTERY_ICON}"
  BATTERY_PERCENTAGE="0"
  ;;
esac

# set color on battery capacity
if [[ ${BATTERY_PERCENTAGE} -lt ${BATTERY_LOW} ]]; then
  _color="#[fg=red,bg=default,bold]"
elif [[ ${BATTERY_PERCENTAGE} -ge 100 ]]; then
  _color="#[fg=green,bg=default]"
else
  _color="#[fg=yellow,bg=default]"
fi

echo "${_color}░ ${ICONS}${RESET}#[bg=default] ${BATTERY_PERCENTAGE}% "
