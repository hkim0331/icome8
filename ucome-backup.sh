#!/bin/sh
DEST=./log

mongoexport -d ucome -c q3_2016 -o ${DEST}/`date +%F`.csv

