#!/bin/sh
# this script must be called from /etc/rc.local.

ruby /srv/ucome/bin/ucome.rb \
         --mongo mongodb://127.0.0.1/ucome \
         --ucome druby://150.69.90.3:4002
