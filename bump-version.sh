#!/bin/sh
# -*- mode: Shell-script; coding: utf-8; -*-

if [ ! $# = 1 ]; then
    echo usage: $0 VERSION
    exit
fi

if [ -e /Users ]; then
    SED="gsed"
else
    SED="sed"
fi

VERSION=$1
TODAY=`date +%F`

FILES="icome-common.rb icome.sh"
for i in ${FILES}; do
    ${SED} -i.bak \
           -e "/^ *VERSION *=/c\
VERSION=\"${VERSION}\"" \
           -e "/^ *UPDATE *=/c\
UPDATE=\"${TODAY}\"" $i
done

echo ${VERSION} > VERSION
