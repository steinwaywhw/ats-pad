FROM ubuntu:14.04

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils wget curl bash make build-essential python xterm git g++ libgtk-3-dev nano 

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


# /root/server
RUN mkdir -p /root/server
WORKDIR /root/server
RUN npm update -g node-gyp
RUN npm install engine.io
RUN npm install primus
RUN npm install pty.js
RUN npm install winston winston-papertrail


# color term
RUN sed -ri 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc
RUN sed -ri 's/force_color_prompt=no/#force_color_prompt=no/g' /root/.bashrc

# ats
WORKDIR /root
RUN apt-get install -y libgmp3-dev
RUN wget -O ats.tgz http://sourceforge.net/projects/ats2-lang/files/latest/download?source=files
RUN tar -xvf ats.tgz
RUN mv ATS2* ats2
RUN rm ats.tgz
WORKDIR /root/ats2 
RUN ./configure
RUN make all
ENV PATSHOME /root/ats2
ENV PATH $PATH:$PATSHOME/bin

WORKDIR /root/server

ADD ./server.js /root/server/server.js
ADD ./index.js /root/server/index.js
ADD ./run.sh /root/server/run.sh
RUN chmod +x ./run.sh

# ENTRYPOINT ["/bin/bash", "-c"]
#EXPOSE 8023