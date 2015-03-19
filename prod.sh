#!/bin/bash

docker run -d --name dnhand -v $(pwd):/usr/src --link mongo:mongo --link redis:redis dnhand
