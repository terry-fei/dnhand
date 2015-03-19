#!/bin/bash

docker run -d --name dnhand -v $(pwd):/usr/src/dnhand --link mongo:mongo --link redis:redis dnhand
