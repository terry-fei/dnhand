FROM dockerfile/nodejs

RUN \
  npm install -g coffee-script && \
  npm install -g nodemon

WORKDIR  /src

CMD ["/bin/bash"]
