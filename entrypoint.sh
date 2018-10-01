#!/bin/sh

echo "Using ${CONFIG_PATH} as config file..."

/bin/confd -onetime -backend file -file ${CONFIG_PATH} -confdir /confd
/tmp/lego.sh
