#!/bin/bash

sudo docker run \
  --network=host \
  --pid=host \
  -e CONFIG_PATH='/config_prod.yml' \
  --mount type=bind,source="$(pwd)"/config_prod.yml,target=/config_prod.yml \
  --mount type=bind,source="$(pwd)"/.lego,target=/.lego \
  hightoxicity/docker-lego
#  --interactive=true \
#  --privileged=true 
