#!/bin/sh
# this script must be called from /etc/rc.local.

sudo -u hkim ruby /srv/ucome/bin/ucome.rb \
         --mongo mongodb://127.0.0.1/ucome \
         --ucome druby://150.69.90.82:9007
