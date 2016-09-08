#!/bin/sh
# ローカル のポート 27017 を mongodb-server の ポート 27017 に転送する。

if [ ! $# = 1 ]; then
    echo usage: $0 mongo-server
    exit
fi

ssh -f -N -L 27017:localhost:27017 $1

