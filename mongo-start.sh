#!/bin/sh
# exec すると Makefile 中で使えないよ。
exec /usr/local/bin/mongod --config ./mongo.conf
