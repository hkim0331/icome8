#!/bin/sh
# standalone のデモ環境

mongod --config ./mongo.conf &
# or
#ssh -f -N -L 27017:localhost:27017 $1

sleep 1
# ucome
#DEBUG=1 MONGO='mongodb://[::1]:27017/test'  UCOME='druby://127.0.0.1:9007' ./ucome.rb &
./ucome --debug &

sleep 1
# acome
#DEBUG=1 UCOME='druby://127.0.0.1:9007' ./acome.rb &
./acome --debug &

sleep 1
# icome
./icome.rb --debug
