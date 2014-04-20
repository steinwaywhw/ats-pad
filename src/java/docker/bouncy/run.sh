#!/bin/bash

cd /root
echo {\"0.0.0.0\" : \"$WORKER_PORT_8023_TCP_ADDR:$WORKER_PORT_8023_TCP_PORT\"} > conf.json
bouncy conf.json 80
