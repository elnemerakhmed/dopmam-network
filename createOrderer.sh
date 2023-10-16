#!/bin/bash
export EXPECTED_PARAM_COUNT=5

if [ $# -ne ${EXPECTED_PARAM_COUNT} ]
then
	echo "Wrong number of parameters for ${0}. Expected ${EXPECTED_PARAM_COUNT} parameter(s), but found $# parameters!" >&2
	exit
fi

export org_name=${1,}
export org_domain=${2}
export org_ca_address=${3}
export org_ca_port=${4}
export org_ca_name=${5}

source .env

export org_name_with_domain=${org_name}.${org_domain}
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/${org_domain}
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/${org_name}/tls-cert.pem

mkdir -p "${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts"
mkdir -p "${FABRIC_CA_CLIENT_HOME}/orderers/${org_domain}"
mkdir -p "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}"
mkdir -p "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/msp/tlscacerts"
mkdir -p "${FABRIC_CA_CLIENT_HOME}/users/Admin@${org_domain}"

retry_count=0
while : ; do
	if [ ! -f "${PWD}/organizations/fabric-ca/${org_name}/tls-cert.pem" -a $retry_count -lt 10 ]; then
		sleep 1
		retry_count=$(expr $retry_count + 1)
	else
		break
	fi
done

if [ ! -f "${PWD}/organizations/fabric-ca/${org_name}/tls-cert.pem" ]; then
	echo "Could not find ca-server tls certificate file" >&2
	exit
fi

fabric-ca-client enroll -u https://admin:adminpw@${org_ca_address}:${org_ca_port} --caname ${org_ca_name}

echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/${org_ca_address}-${org_ca_port}-${org_ca_name}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/${org_ca_address}-${org_ca_port}-${org_ca_name}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/${org_ca_address}-${org_ca_port}-${org_ca_name}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/${org_ca_address}-${org_ca_port}-${org_ca_name}.pem
    OrganizationalUnitIdentifier: orderer" > "${FABRIC_CA_CLIENT_HOME}/msp/config.yaml"

fabric-ca-client register --caname ${org_ca_name} --id.name orderer --id.secret ordererpw --id.type orderer

fabric-ca-client register --caname ${org_ca_name} --id.name ${org_name}admin --id.secret ${org_name}adminpw --id.type admin

fabric-ca-client enroll -u https://orderer:ordererpw@${org_ca_address}:${org_ca_port} --caname ${org_ca_name} -M "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/msp" --csr.hosts ${org_name_with_domain} --csr.hosts ${org_ca_address}

cp "${FABRIC_CA_CLIENT_HOME}/msp/config.yaml" "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/msp/config.yaml"

fabric-ca-client enroll -u https://orderer:ordererpw@${org_ca_address}:${org_ca_port} --caname ${org_ca_name} -M "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls" --enrollment.profile tls --csr.hosts ${org_name_with_domain} --csr.hosts ${org_ca_address}

cp "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/tlscacerts"/* "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/ca.crt"
cp "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/signcerts"/* "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/server.crt"
cp "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/keystore"/* "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/server.key"
cp "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/tlscacerts"/* "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/msp/tlscacerts/tlsca.${org_domain}-cert.pem"
cp "${FABRIC_CA_CLIENT_HOME}/orderers/${org_name_with_domain}/tls/tlscacerts"/* "${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.${org_domain}-cert.pem"

fabric-ca-client enroll -u https://${org_name}admin:${org_name}adminpw@${org_ca_address}:${org_ca_port} --caname ${org_ca_name} -M "${FABRIC_CA_CLIENT_HOME}/users/Admin@${org_domain}/msp"

cp "${FABRIC_CA_CLIENT_HOME}/msp/config.yaml" "${FABRIC_CA_CLIENT_HOME}/users/Admin@${org_domain}/msp/config.yaml"
