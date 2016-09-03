#!/bin/sh

mongoexport -d ucome -c q3_2016 -o /srv/icome8/backup/`date +%F`.csv

