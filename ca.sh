#!/bin/bash

source .env

printInfo

mkdir -p "organizations/ordererOrganizations"
mkdir -p "organizations/peerOrganizations"

docker-compose -f "docker/docker-compose-ca.yaml" up -d

./createOrg.sh dopmam moh.ps localhost 7054 ca-dopmam
./createOrg.sh shifa moh.ps localhost 8054 ca-shifa
./createOrg.sh naser moh.ps localhost 9054 ca-naser
./createOrderer.sh orderer moh.ps localhost 10054 ca-orderer
