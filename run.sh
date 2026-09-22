#!/bin/sh
exec docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
  -e ANSIBLE_COLLECTIONS_PATH=/work/.ansible/collections \
  -e ANSIBLE_ROLES_PATH=/work/.ansible/roles \
  -v "$PWD":/work -w /work \
  5hash-tools "$@"
