FROM docker.cn/docker/node:latest

RUN \
  cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
  echo "deb http://mirrors.aliyun.com/debian/ wheezy main non-free contrib" > /etc/apt/sources.list && \
  echo "deb http://mirrors.aliyun.com/debian/ wheezy-proposed-updates main non-free contrib" >> /etc/apt/sources.list && \
  echo "deb-src http://mirrors.aliyun.com/debian/ wheezy main non-free contrib" >> /etc/apt/sources.list && \
  echo "deb-src http://mirrors.aliyun.com/debian/ wheezy-proposed-updates main non-free contrib" >> /etc/apt/sources.list

RUN apt-get update && \
  apt-get install -y python-imaging && \
  apt-get install -y python-tornado

RUN \
  npm install -g coffee-script && \
  npm install -g pm2 && \
  pm2 dump

EXPOSE 80

ENV VIRTUAL_HOST n.feit.me

WORKDIR  /src

CMD ["pm2", "start", "boot.json"， "--no-daemon"]
