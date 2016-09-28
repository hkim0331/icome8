#!/bin/sh
# standalone のデモ環境

# mongodb はさすがにローカルフォルダに準備できない。
#mongod --config ./mongo.conf

# ucome
DEBUG=1 MONGO='mongodb://[::1]:27017/test'  UCOME='druby://127.0.0.1:9007' ./ucome.rb &

# acome
DEBUG=1 UCOME='druby://127.0.0.1:9007' ./acome.rb &

# icome
./icome.rb --debug &




