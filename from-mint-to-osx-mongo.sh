#!/bin/sh
# mint から mongo で tmac2.local の mongodb に転送する。
if [ ! $# = 1 ]; then
	echo usage: $0 mongodb_server_machine
    exit
fi

ssh -f -N -L 27017:localhost:27017 $1
