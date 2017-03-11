#!/bin/sh
# exec すると Makefile 中で使えない。
exec /usr/local/bin/mongod --config ./mongo.conf


