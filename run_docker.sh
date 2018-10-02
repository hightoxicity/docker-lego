#!/bin/bash

sudo docker run \
  --interactive=true \
  --network=host \
  --pid=host \
  -e CONFIG_PATH='/config_prod.yml' \
  --mount type=bind,source="$(pwd)"/config_prod.yml,target=/config_prod.yml \
  --mount type=bind,source="$(pwd)"/.lego,target=/.lego \
  djnos/docker-lego
#  --interactive=true \
#  --privileged=true 
