#!/bin/bash

source .env

printInfo

mkdir ccp

function one_line_pem {
	echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' ${1}`"
}

function json_ccp {
	local PP=$(one_line_pem ${7})
	local CP=$(one_line_pem ${8})
	sed -e "s/\${org_name_lowercase}/${1}/" \
	    -e "s/\${org_name_uppercase}/${2}/" \
	    -e "s/\${org_domain}/${3}/" \
	    -e "s/\${org_msp}/${4}/" \
	    -e "s/\${org_port}/${5}/" \
	    -e "s/\${org_ca_port}/${6}/" \
	    -e "s#\${org_pem}#${PP}#" \
	    -e "s#\${org_ca_pem}#${CP}#" \
	    template/ccp-template.json
}

function org_ccp {
	org_name_lowercase=${1}
	org_name_uppercase=${1^}
	org_domain=${2}
	org_msp=${3}
	org_port=${4}
	org_ca_port=${5}

	org_pem=organizations/peerOrganizations/${org_name_lowercase}.${org_domain}/tlsca/tlsca.${org_name_lowercase}.${org_domain}-cert.pem
	org_ca_pem=organizations/peerOrganizations/${org_name_lowercase}.${org_domain}/ca/ca.${org_name_lowercase}.${org_domain}-cert.pem
	echo "$(json_ccp ${org_name_lowercase} ${org_name_uppercase} ${org_domain} ${org_msp} ${org_port} ${org_ca_port} ${org_pem} ${org_ca_pem})" > ccp/connection-${org_name_lowercase}.json
}

org_ccp dopmam moh.ps DopmamMSP 7051 7054
org_ccp shifa  moh.ps ShifaMSP 8051 8054
org_ccp naser  moh.ps NaserMSP 9051 9054
