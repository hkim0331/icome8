#!/bin/sh
# must exec on ucome server.

# ufw allow 9007/tcp
ufw allow proto tcp from 150.69.0.0/16 to any port 9007
