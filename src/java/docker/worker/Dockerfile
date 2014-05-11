FROM stackbrew/ubuntu:13.10

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils

RUN apt-get install -y wget
RUN apt-get install -y bash
RUN apt-get install -y make
RUN apt-get install -y build-essential
RUN apt-get install -y python
RUN apt-get install -y xterm
#RUN apt-get install -y ncurses-term

# /root/nodejs
WORKDIR /root
RUN wget -O nodejs.tgz http://nodejs.org/dist/v0.10.26/node-v0.10.26-linux-x64.tar.gz
RUN tar -xvf nodejs.tgz
RUN rm nodejs.tgz
RUN mv node* nodejs
ENV PATH $PATH:/root/nodejs/bin

# /root/server
RUN mkdir -p /root/server
WORKDIR /root/server
RUN npm update -g node-gyp
RUN npm update -g npm
RUN npm install term.js
RUN npm install socket.io
RUN npm install express
RUN npm install pty.js

ADD ./server.js /root/server/server.js
ADD ./index.js /root/server/index.js

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
# ENTRYPOINT ["/bin/bash", "-c"]
EXPOSE 8023