FROM docker.cn/docker/node:latest

RUN apt-get install -y python-imaging

RUN \
  npm install -g coffee-script && \
  npm install -g pm2 

ENV NODE_ENV production
ENV MONGO_HOST mongo
ENV MONGO_PORT 27017
ENV MONGO_DBNAME dnhand

WORKDIR  /src

CMD ["/bin/bash"]
