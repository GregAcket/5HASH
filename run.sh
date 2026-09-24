#!/bin/sh
exec docker run --rm -it \
  -e HOME=/tmp \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e TF_VAR_db_pwd \
  -e ANSIBLE_COLLECTIONS_PATH=/work/.ansible/collections \
  -e ANSIBLE_ROLES_PATH=/work/.ansible/roles \
  -e ANSIBLE_CONFIG=/work/ansible/ansible.cfg \
  -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
  -v "$PWD":/work -w /work \
  5hash-tools sh -c '"$@"; rc=$?; chown -R "$HOST_UID:$HOST_GID" /work 2>/dev/null; exit $rc' sh "$@"
