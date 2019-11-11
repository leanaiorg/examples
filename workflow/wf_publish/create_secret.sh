#!/bin/bash

ssh-keyscan github.com > /tmp/known_hosts

kubectl create secret generic git-creds \
    --from-file=ssh=kaniko_key \
    --from-file=known_hosts=/tmp/known_hosts
