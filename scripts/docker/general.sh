#!/bin/bash
IMAGES=(
  python
  python:2.7
  redis
  nginx
  mongo
)

for i in "${IMAGES[@]}"
do
  docker pull "$i"
done
