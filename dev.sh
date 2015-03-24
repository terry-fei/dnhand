#!/bin/bash

docker run -it --rm -v $(pwd):/usr/src -p 80:80 --link mongo:mongo --link redis:redis \
  -e VIRTUAL_HOST=dnhandtmp.feit.me \
  dnhand bash
