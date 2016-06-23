#!/bin/bash
IMAGES=(
  busybox
)

for i in "${IMAGES[@]}"
do
  docker pull "$i"
done
