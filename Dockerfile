FROM dockerfile/nodejs

MAINTAINER ifeiteng <ifeiteng@gmail.com>

RUN \
  npm install -g coffee-script && \
  npm install -g nodemon

WORKDIR  /src

CMD ["/bin/bash"]
