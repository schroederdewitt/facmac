#!/bin/bash
HASH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
GPU=$1
name=${USER}_facmac_GPU_${GPU}_${HASH}

echo "Launching container named '${name}' on GPU '${GPU}'"
# Launches a docker container using our image, and runs the provided command

if hash nvidia-docker 2>/dev/null; then
  cmd=nvidia-docker
else
  cmd=docker
fi
echo "${@:2}" 2>&1 >> log.txt

docker run -it \
    --gpus "device=${1}" \
    --name $name \
    --user $(id -u) \
    -v `pwd`/src:/home/duser/entryfolder \
    -e PYTHONPATH=/home/duser/entryfolder \
    -t facmac \
    ${@:2}
