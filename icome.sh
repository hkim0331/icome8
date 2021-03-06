#!/bin/sh
# wrapper is necessary for not to quit icome launched.

ps ax | egrep '[i]come.rb' >/dev/null
if [ "$?" -eq 0 ]; then
    echo icome はすでに起動しています。
    exit
fi
echo icome の起動には 5 秒くらいかかります。

if [ -f /home/t/hkimura/icome8/icome.rb ]; then
    ICOME=/home/t/hkimura/icome8/icome.rb
    UCOME='druby://150.69.90.3:4002' nohup ${ICOME} 2>/dev/null &

    # in isc, launch xwatch-ss simultaneously.
    XWATCH=/home/t/hkimura/xwatch-ss
    if [ -e ${XWATCH} ]; then
        nohup ${XWATCH}/xwatch-ss.rb \
              --image ${XWATCH}/images/ghost-busters.png \
              --conf /home/t/hkimura/Desktop/xwatch-ss.conf 2>/dev/null &
    fi
else
    echo "for debug, consider to use --debug option."
    UCOME='druby://150.69.90.3:4002' ./icome.rb $@
fi
