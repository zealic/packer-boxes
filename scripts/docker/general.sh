#!/bin/bash
IMAGES=(
  python
  python:2.7
  nginx
  mongo
)

for i in "${IMAGES[@]}"
do
  docker pull "$i"
done
