#!/bin/bash

source .env

printInfo

chaincode_source_path=${PWD}/../dopmam-chaincode
chaincode_name=dopmam_smart_contract
chaincode_sequence=1
chaincode_packages_directory=$PWD/chaincode-packages
orderer_address=localhost
orderer_port=10050
orderer_name=orderer.moh.ps
orderer_tls_cert=${PWD}/organizations/ordererOrganizations/moh.ps/orderers/orderer.moh.ps/msp/tlscacerts/tlsca.moh.ps-cert.pem

function package_chaincode(){
	EXPECTED_PARAM_COUNT=4
	
	if [ $# -ne ${EXPECTED_PARAM_COUNT} ]
	then
	        echo "Wrong number of parameters for ${FUNCNAME}. Expected ${EXPECTED_PARAM_COUNT} parameter(s), but found $# parameters!" >&2
	        exit
	fi
	
	chaincode_source_path=${1}
	chaincode_name=${2}
	chaincode_sequence=${3}
	chaincode_packages_directory=${4}
	
	source .env
	
	chaincode_build_path=${chaincode_source_path}/build/install/chaincode
	org_name=dopmam
	
	mkdir -p ${chaincode_packages_directory}
	
	pushd "${chaincode_source_path}" > /dev/null
	./gradlew installDist
	popd > /dev/null
	
	setOrganization ${org_name}
	
	peer lifecycle chaincode package "${chaincode_packages_directory}/${chaincode_name}.tar.gz" --path "${chaincode_build_path}" --lang java --label ${chaincode_name}_${chaincode_sequence}
}

function install_chaincode_on_org(){
	EXPECTED_PARAM_COUNT=3
	
	if [ $# -ne ${EXPECTED_PARAM_COUNT} ]
	then
	        echo "Wrong number of parameters for ${FUNCNAME}. Expected ${EXPECTED_PARAM_COUNT} parameter(s), but found $# parameters!" >&2
	        exit
	fi

	chaincode_packages_directory=${1}	
	chaincode_name=${2}
	org_name=${3}
	
	source .env
	
	setOrganization ${org_name}
	peer lifecycle chaincode install "${chaincode_packages_directory}/${chaincode_name}.tar.gz"
}

function approve_chaincode_on_org(){
	EXPECTED_PARAM_COUNT=8
	
	if [ $# -ne ${EXPECTED_PARAM_COUNT} ]
	then
	        echo "Wrong number of parameters for ${FUNCNAME}. Expected ${EXPECTED_PARAM_COUNT} parameter(s), but found $# parameters!" >&2
	        exit
	fi
	
	chaincode_name=${1}
	chaincode_sequence=${2}
	channel_id=${3}
	org_name=${4}
	orderer_address=${5}
	orderer_port=${6}
	orderer_name=${7}
	orderer_tls_cert=${8}
	
	source .env
	
	setOrganization ${org_name}
	
	peer lifecycle chaincode queryinstalled > installed.txt
	package_id=$(sed -n "/${chaincode_name}_${chaincode_sequence}/{s/^Package ID: //; s/, Label:.*$//; p;}" installed.txt)
	rm -f installed.txt
	
	peer lifecycle chaincode approveformyorg -o ${orderer_address}:${orderer_port} --ordererTLSHostnameOverride ${orderer_name} --channelID ${channel_id} --name ${chaincode_name} --version ${chaincode_sequence} --package-id ${package_id} --sequence ${chaincode_sequence} --tls --cafile "${orderer_tls_cert}"
}

package_chaincode "${chaincode_source_path}" "${chaincode_name}" "${chaincode_sequence}" "${chaincode_packages_directory}"

install_chaincode_on_org "${chaincode_packages_directory}" "${chaincode_name}" "dopmam"
install_chaincode_on_org "${chaincode_packages_directory}" "${chaincode_name}" "shifa"
install_chaincode_on_org "${chaincode_packages_directory}" "${chaincode_name}" "naser"

channel_id=dopmam-shifa
approve_chaincode_on_org "${chaincode_name}" "${chaincode_sequence}" "${channel_id}" "dopmam" "${orderer_address}" "${orderer_port}" "${orderer_name}" "${orderer_tls_cert}"
approve_chaincode_on_org "${chaincode_name}" "${chaincode_sequence}" "${channel_id}" "shifa" "${orderer_address}" "${orderer_port}" "${orderer_name}" "${orderer_tls_cert}"

channel_id=dopmam-naser
approve_chaincode_on_org "${chaincode_name}" "${chaincode_sequence}" "${channel_id}" "dopmam" "${orderer_address}" "${orderer_port}" "${orderer_name}" "${orderer_tls_cert}"
approve_chaincode_on_org "${chaincode_name}" "${chaincode_sequence}" "${channel_id}" "naser" "${orderer_address}" "${orderer_port}" "${orderer_name}" "${orderer_tls_cert}"

setOrganization dopmam
channel_id=dopmam-shifa
peers_info=(--peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/dopmam.moh.ps/peers/peer0.dopmam.moh.ps/tls/ca.crt" --peerAddresses localhost:8051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/shifa.moh.ps/peers/peer0.shifa.moh.ps/tls/ca.crt")

peer lifecycle chaincode commit -o ${orderer_address}:${orderer_port} --ordererTLSHostnameOverride ${orderer_name} --channelID ${channel_id} --name ${chaincode_name} --version ${chaincode_sequence} --sequence ${chaincode_sequence} --tls --cafile "${orderer_tls_cert}" "${peers_info[@]}"

peer lifecycle chaincode querycommitted --channelID ${channel_id} --name ${chaincode_name} --cafile "${orderer_tls_cert}"

c='{"function":"initLedger","Args":[]}'

peer chaincode invoke -o ${orderer_address}:${orderer_port} --ordererTLSHostnameOverride ${orderer_name} --tls --cafile "${orderer_tls_cert}" -C ${channel_id} -n ${chaincode_name} "${peers_info[@]}" -c "$c"

channel_id=dopmam-naser
peers_info=(--peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/dopmam.moh.ps/peers/peer0.dopmam.moh.ps/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/naser.moh.ps/peers/peer0.naser.moh.ps/tls/ca.crt")

peer lifecycle chaincode commit -o ${orderer_address}:${orderer_port} --ordererTLSHostnameOverride ${orderer_name} --channelID ${channel_id} --name ${chaincode_name} --version ${chaincode_sequence} --sequence ${chaincode_sequence} --tls --cafile "${orderer_tls_cert}" "${peers_info[@]}"

peer lifecycle chaincode querycommitted --channelID ${channel_id} --name ${chaincode_name} --cafile "${orderer_tls_cert}"

c='{"function":"initLedger","Args":[]}'

peer chaincode invoke -o ${orderer_address}:${orderer_port} --ordererTLSHostnameOverride ${orderer_name} --tls --cafile "${orderer_tls_cert}" -C ${channel_id} -n ${chaincode_name} "${peers_info[@]}" -c "$c"
