#!/bin/bash
ans=$(echo -e "" | rofi -p "Buscar paquetes en Ubuntu:" -dmenu)
rs=$?
if [ $rs -eq 0 ] && [ "$ans" ]
then
    URL="https://packages.ubuntu.com/search?suite=default&section=all&arch=any&keywords=${ans}"
    sensible-browser "${URL}"
fi
