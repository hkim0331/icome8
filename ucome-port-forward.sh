#!/bin/sh
# ローカル のポート 9007 を $1の ポート 9007 に転送する。

if [ ! $# = 1 ]; then
    echo usage: $0 ucome-server
    exit
fi

ssh -f -N -L 9007:localhost:9007 $1

