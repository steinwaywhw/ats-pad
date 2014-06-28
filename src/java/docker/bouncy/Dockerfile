FROM ubuntu:14.04

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y apt-utils wget curl python bash make build-essential

# /root/nodejs
WORKDIR /root
RUN mkdir .npm
RUN mkdir nodejs
ENV PATH $PATH:/root/.npm/bin

WORKDIR /root/nodejs
RUN curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
RUN ./configure --prefix=/root/.npm
RUN V= make install -j4
RUN curl https://www.npmjs.org/install.sh | clean=no sh

# /root/redis
WORKDIR /root
RUN wget http://download.redis.io/redis-stable.tar.gz
RUN tar -xvf redis-stable.tar.gz
RUN rm redis-stable.tar.gz
RUN mv redis-stable redis
WORKDIR /root/redis
RUN make
RUN make install

# bouncy
# WORKDIR /root
# RUN npm install -g bouncy
# ADD run.sh /root/run.sh
# RUN chmod +x run.sh

# proxy
WORKDIR /root
RUN npm install redis 
RUN npm install bouncy
RUN npm install winston
RUN npm install winston-papertrail
RUN npm install url
ADD proxy.js /root/proxy.js
ADD index.js /root/index.js

# EXPOSE 80
# use docker run --expose="" instead




