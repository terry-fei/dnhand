#!/bin/bash

docker run -it --rm -v $(pwd):/src -p 80:80 --link mongodb:mongo --link redis:redis dnhand /bin/bash
