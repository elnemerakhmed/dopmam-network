#!/bin/bash

source .env

printInfo

docker-compose -f "docker/docker-compose-ca.yaml" -f "docker/docker-compose-dopmam-network.yaml" down --volumes --remove-orphans

docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf ccp chaincode-packages channel-artifacts organizations system-genesis-block'
