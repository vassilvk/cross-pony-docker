#!/usr/bin/env bash
trap "exit 0" ERR

dangling_images=$(docker images -q --filter "dangling=true")

if [ ! -z "$dangling_images" ]; then
  docker rmi -f $dangling_images
fi
