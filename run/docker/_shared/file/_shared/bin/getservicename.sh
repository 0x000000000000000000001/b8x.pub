#!/bin/bash

echo $(docker inspect $(cat /etc/hostname) | jq -r '.[0].Config.Labels."com.docker.swarm.service.name"')