#!/bin/bash

source .env

printInfo

updateAnchorPeerForOrganization() {
	org_name=${1}
	org_domain=${2}
	org_msp=${3}
	org_port=${4}
	orderer_address=${5}
	orderer_port=${6}
	orderer_name=${7}
	orderer_domian=${8}
	channel_name=${9}

	setOrganization ${org_name}
	peer channel fetch config "channel-artifacts/config_block.pb" -o ${orderer_address}:${orderer_port} --ordererTLSHostnameOverride ${orderer_name}.${orderer_domian} -c ${channel_name} --tls --cafile "${PWD}/organizations/ordererOrganizations/${orderer_domian}/orderers/${orderer_name}.${orderer_domian}/msp/tlscacerts/tlsca.${orderer_domian}-cert.pem"

	configtxlator proto_decode --input "channel-artifacts/config_block.pb" --type common.Block --output "channel-artifacts/config_block.json"
	jq .data.data[0].payload.data.config "channel-artifacts/config_block.json" > "channel-artifacts/config.json"
	cp "channel-artifacts/config.json" "channel-artifacts/config_copy.json"
	jq '.channel_group.groups.Application.groups.'"${org_msp}"'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.'"${org_name}.${org_domain}"'","port": '"${org_port}"'}]},"version": "0"}}' "channel-artifacts/config_copy.json" > "channel-artifacts/modified_config.json"
    
	configtxlator proto_encode --input "channel-artifacts/config.json" --type common.Config --output "channel-artifacts/config.pb"
	configtxlator proto_encode --input "channel-artifacts/modified_config.json" --type common.Config --output "channel-artifacts/modified_config.pb"
	configtxlator compute_update --channel_id ${channel_name} --original "channel-artifacts/config.pb" --updated "channel-artifacts/modified_config.pb" --output "channel-artifacts/config_update.pb"

	configtxlator proto_decode --input "channel-artifacts/config_update.pb" --type common.ConfigUpdate --output "channel-artifacts/config_update.json"

	echo '{"payload":{"header":{"channel_header":{"channel_id":"'"${channel_name}"'", "type":2}},"data":{"config_update":'$(cat "channel-artifacts/config_update.json")'}}}' | jq . > "channel-artifacts/config_update_in_envelope.json"
	configtxlator proto_encode --input "channel-artifacts/config_update_in_envelope.json" --type common.Envelope --output "channel-artifacts/config_update_in_envelope.pb"
    
    peer channel update -f "channel-artifacts/config_update_in_envelope.pb" -c ${channel_name} -o ${orderer_address}:${orderer_port} --ordererTLSHostnameOverride ${orderer_name}.${orderer_domian} --tls --cafile "${PWD}/organizations/ordererOrganizations/${orderer_domian}/orderers/${orderer_name}.${orderer_domian}/msp/tlscacerts/tlsca.${orderer_domian}-cert.pem"


	rm -f "channel-artifacts/config_block.json"
	rm -f "channel-artifacts/config_block.pb"
	rm -f "channel-artifacts/config_copy.json"
	rm -f "channel-artifacts/config.pb"
	rm -f "channel-artifacts/config_update_in_envelope.json"
	rm -f "channel-artifacts/config_update_in_envelope.pb"
	rm -f "channel-artifacts/config_update.json"
	rm -f "channel-artifacts/config_update.pb"
	rm -f "channel-artifacts/modified_config.json"
	rm -f "channel-artifacts/modified_config.pb"
}

updateAnchorPeerForOrganization dopmam moh.ps DopmamMSP 7051 localhost 10050 orderer moh.ps dopmam-shifa
updateAnchorPeerForOrganization shifa  moh.ps ShifaMSP  8051 localhost 10050 orderer moh.ps dopmam-shifa
updateAnchorPeerForOrganization naser  moh.ps NaserMSP  9051 localhost 10050 orderer moh.ps dopmam-naser
