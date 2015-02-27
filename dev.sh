#!/bin/bash

docker run -it --rm -v $(pwd):/src --link mongodb:mongo --link redis:redis \
  -e NODE_ENV=development \
  -e MONGO_HOST=mongo \
  -e MONGO_PORT=27017 \
  -e MONGO_DBNAME=dnhand_dev \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -e WECHAT_TOKEN=1NtYFf4S3VIN \
  -e WECHAT_APPID=wxc49d99a484205dd0 \
  -e WECHAT_SECRET=75676597753ddb51c8d74273650daa76 \
  -e WECHAT_HAS_ADVANCED_INTERFACE=true \
  -e WECHAT_TEST_OPENID=ofu7Ts4-v3xMIqAXfkEbyuEvb_Uc \
  -e SESSION_SECRET=0dNOxLj7zFaa \
  -e NODE_LISTEN_PORT=80 \
  dnhand /bin/bash
