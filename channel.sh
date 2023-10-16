#!/bin/bash

source .env

printInfo

createChannelTransaction() {
	orderer_address=${1}
	orderer_port=${2}
	orderer_name=${3}
	orderer_domain=${4}
	channel_name=${5}

	retry_count=0
	rc=1
	while [ $rc -ne 0 -a $retry_count -lt 10 ] ; do
		sleep 1
		peer channel create -o ${orderer_address}:${orderer_port} -c ${channel_name} --ordererTLSHostnameOverride ${orderer_name}.${orderer_domain} -f "channel-artifacts/${channel_name}.tx" --outputBlock "channel-artifacts/${channel_name}.block" --tls --cafile "${PWD}/organizations/ordererOrganizations/${orderer_domain}/orderers/${orderer_name}.${orderer_domain}/msp/tlscacerts/tlsca.${orderer_domain}-cert.pem"
		rc=$?
		retry_count=$(expr $retry_count + 1)
	done
}

joinChannel() {
	channel_name=${1}

	retry_count=0
	rc=1
	while [ $rc -ne 0 -a $retry_count -lt 10 ] ; do
		sleep 1
		peer channel join -b "channel-artifacts/${channel_name}.block"
		rc=$?
		retry_count=$(expr $retry_count + 1)
	done
}

export FABRIC_CFG_PATH=${PWD}/configtx

configtxgen -profile OrdererGenesis -channelID system-channel -outputBlock "system-genesis-block/genesis.block"
docker-compose -f "docker/docker-compose-dopmam-network.yaml" up -d
configtxgen -profile DopmamShifaChannel -outputCreateChannelTx "channel-artifacts/dopmam-shifa.tx" -channelID dopmam-shifa
configtxgen -profile DopmamNaserChannel -outputCreateChannelTx "channel-artifacts/dopmam-naser.tx" -channelID dopmam-naser

setOrganization dopmam
createChannelTransaction localhost 10050 orderer moh.ps dopmam-shifa
createChannelTransaction localhost 10050 orderer moh.ps dopmam-naser
joinChannel dopmam-shifa
joinChannel dopmam-naser

setOrganization shifa
joinChannel dopmam-shifa

setOrganization naser
joinChannel dopmam-naser
