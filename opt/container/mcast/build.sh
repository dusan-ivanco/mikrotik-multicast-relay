#!/bin/bash -e

# SOURCE
# https://github.com/alsmith/multicast-relay

# PLATFORM
# docker buildx ls

docker buildx build --no-cache --platform "linux/arm/v7" --output "type=docker" --tag "mcast" .
docker save mcast --output ../mcast_arm32.tar

docker buildx build --no-cache --platform "linux/arm64" --output "type=docker" --tag "mcast" .
docker save mcast --output ../mcast_arm64.tar
