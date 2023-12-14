#!/usr/bin/env bash
#
ID=$1

case $ID in
  0)
    echo "🯰"
    ;;
  1)
    echo "🯱"
    ;;
  2)
    echo "🯲"
    ;;
  3)
    echo "🯳"
    ;;
  4)
    echo "🯴"
    ;;
  5)
    echo "🯵"
    ;;
  6)
    echo "🯶"
    ;;
  7)
    echo "🯷"
    ;;
  8)
    echo "🯸"
    ;;
  9)
    echo "🯹"
    ;;
  *)
    echo $ID
    ;;
esac
