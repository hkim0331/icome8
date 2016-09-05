#!/bin/sh

VERSION="0.1.3"

ICOME=/home/t/hkimura/bin/icome7.rb
SS=/edu/bin/watch-ss

if [ "$1" = "--version" ]; then
    echo ${VERSION}
    exit
fi

# singleton check
ps ax | egrep '[i]come8.rb' >/dev/null
if [ "$?" -eq 0 ]; then
    echo "icome はすでに起動しています。"
    exit
fi

# launch icome
if [ -e ${ICOME} ]; then
    echo "icome の起動には 5 秒くらいかかります。"
    UCOME='druby://150.69.90.81:9007' nohup ${ICOME} 2>/dev/null &
fi

# additional scripts
if [ -e ${SS} ]; then
    nohup ${SS} 2>/dev/null &
fi
