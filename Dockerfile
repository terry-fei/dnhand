FROM dockerfile/nodejs

MAINTAINER ifeiteng <ifeiteng@gmail.com>

ENV NODE_ENV=developmetn

RUN \
  npm install -g coffee-script && \
  npm install -g nodemon

WORKDIR  /src

CMD ["/bin/bash"]
