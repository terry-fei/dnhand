FROM node:0.10

RUN \
  npm install -g coffee-script && \
  npm install -g pm2 && \
  pm2 dump

EXPOSE 80

ENV VIRTUAL_HOST n.feit.me

WORKDIR  /usr/src

CMD ["npm", "start"]
