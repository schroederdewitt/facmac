#!/bin/bash
HASH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
name=${USER}_facmac_${HASH}

echo "Launching container named '${name}' on CPU'"
# Launches a docker container using our image, and runs the provided command

if hash nvidia-docker 2>/dev/null; then
  cmd=nvidia-docker
else
  cmd=docker
fi

 ${cmd} run --rm \
    --cpuset-cpus=0-5 \
    --name $name \
    -v `pwd`:/home/duser/facmac \
    -e PYTHONPATH=/home/duser/facmac \
    -t pymarl \
    ${@:1}
