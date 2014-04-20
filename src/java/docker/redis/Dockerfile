FROM stackbrew/ubuntu:13.10

RUN apt-get update

RUN apt-get install -y wget
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

EXPOSE 6379

