#!/usr/bin/env bash
#
ID=$(($1))
FORMAT=$2

if [ "$FORMAT" = "none" ]; then
  echo $ID;
fi

if [ "$FORMAT" = "digital" ]; then
  case $ID in
    0) echo "🯰";;
    1) echo "🯱";;
    2) echo "🯲";;
    3) echo "🯳";;
    4) echo "🯴";;
    5) echo "🯵";;
    6) echo "🯶";;
    7) echo "🯷";;
    8) echo "🯸";;
    9) echo "🯹";;
    *) echo $ID;;
  esac
fi

if [ "$FORMAT" = "fsquare" ]; then
  case $ID in
    0) echo "󰎡";;
    1) echo "󰎤";;
    2) echo "󰎧";;
    3) echo "󰎪";;
    4) echo "󰎭";;
    5) echo "󰎱";;
    6) echo "󰎳";;
    7) echo "󰎶";;
    8) echo "󰎹";;
    9) echo "󰎼";;
    *) echo $ID;;
  esac
fi

if [ "$FORMAT" = "hsquare" ]; then
  case $ID in
    0) echo "󰎣";;
    1) echo "󰎦";;
    2) echo "󰎩";;
    3) echo "󰎬";;
    4) echo "󰎮";;
    5) echo "󰎰";;
    6) echo "󰎵";;
    7) echo "󰎸";;
    8) echo "󰎻";;
    9) echo "󰎾";;
    *) echo $ID;;
  esac
fi

if [ "$FORMAT" = "dsquare" ]; then
  case $ID in
    0) echo "󰎢";;
    1) echo "󰎥";;
    2) echo "󰎨";;
    3) echo "󰎫";;
    4) echo "󰎲";;
    5) echo "󰎯";;
    6) echo "󰎴";;
    7) echo "󰎷";;
    8) echo "󰎺";;
    9) echo "󰎽";;
    *) echo $ID;;
  esac
fi

if [ "$FORMAT" = "roman" ]; then
  case $ID in
    0) echo " ";;
    1) echo "󱂈";;
    2) echo "󱂉";;
    3) echo "󱂊";;
    4) echo "󱂋";;
    5) echo "󱂌";;
    6) echo "󱂍";;
    7) echo "󱂎";;
    8) echo "󱂏";;
    9) echo "󱂐";;
    *) echo $ID;;
  esac
fi

if [ "$FORMAT" = "super" ]; then
  case $ID in
    0) echo "⁰";;
    1) echo "¹";;
    2) echo "²";;
    3) echo "³";;
    4) echo "⁴";;
    5) echo "⁵";;
    6) echo "⁶";;
    7) echo "⁷";;
    8) echo "⁸";;
    9) echo "⁹";;
    *) echo $ID;;
  esac
fi

if [ "$FORMAT" = "sub" ]; then
  case $ID in
    0) echo "₀";;
    1) echo "₁";;
    2) echo "₂";;
    3) echo "₃";;
    4) echo "₄";;
    5) echo "₅";;
    6) echo "₆";;
    7) echo "₇";;
    8) echo "₈";;
    9) echo "₉";;
    *) echo $ID;;
  esac
fi
