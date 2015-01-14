#!/bin/bash

docker run -d --name dnhand -v $(pwd):/src -p 7080:80 --link mongodb:mongo --link redis:redis \
  dnhand pm2 start boot.json --no-daemon
