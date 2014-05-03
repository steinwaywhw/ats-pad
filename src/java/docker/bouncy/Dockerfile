FROM stackbrew/ubuntu:13.10

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y wget
RUN apt-get install -y bash
RUN apt-get install -y make
RUN apt-get install -y build-essential

# /root/nodejs
WORKDIR /root
RUN wget -O nodejs.tgz http://nodejs.org/dist/v0.10.26/node-v0.10.26-linux-x64.tar.gz
RUN tar -xvf nodejs.tgz
RUN rm nodejs.tgz
RUN mv node* nodejs
ENV PATH $PATH:/root/nodejs/bin

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
RUN npm install util
RUN npm install url
ADD proxyserver.js /root/proxyserver.js
ADD index.js /root/index.js

# EXPOSE 80
# use docker run --expose="" instead




