#!/usr/bin/env bash
docker build -f Dockerfile -t vassilvk/cross-pony:latest .
./build/cleanup.sh