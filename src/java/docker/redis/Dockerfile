FROM ubuntu:14.04
RUN apt-get update

RUN apt-get install -y wget curl python
RUN apt-get install -y bash
RUN apt-get install -y make
RUN apt-get install -y build-essential

WORKDIR /root
RUN wget http://download.redis.io/redis-stable.tar.gz
RUN tar -xvf redis-stable.tar.gz
RUN rm redis-stable.tar.gz
RUN mv redis-stable redis

WORKDIR /root/redis
RUN make
RUN make install

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

# redsmin
RUN npm install redsmin -g
RUN RKEY=5399f9027ae7f0a9400002a1 redsmin set_key 

WORKDIR /root
ADD ./run.sh /root/run.sh
RUN chmod +x ./run.sh
#EXPOSE 6379

