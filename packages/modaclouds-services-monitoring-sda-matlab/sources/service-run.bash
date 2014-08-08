#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

MODACLOUDS_MONITORING_SDA_MATLAB_HOME='@{package:root}'
SDA_MATLAB_HOME='@{definitions:environment:SDA_MATLAB_HOME}'
SDA_MATLAB_CONF='@{definitions:environment:SDA_MATLAB_CONF}'
MCR_HOME='@{definitions:environment:MCR_HOME}'
JAVA_HOME='@{definitions:environment:JAVA_HOME}'

test -n "${MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_IP}"
test -n "${MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_PORT}"

test -n "${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP}"
test -n "${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT}"

test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}"

export MCR_HOME
export JAVA_HOME
export PATH="${JAVA_HOME}/bin:${PATH}"

cd -- "${SDA_MATLAB_HOME}"

cat \
	>|"${SDA_MATLAB_CONF}/dda.properties" \
	<<EOS
dda_server.port=${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT}
dda_server.address=${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP}
EOS

cat \
	>|"${SDA_MATLAB_CONF}/kb.properties" \
	<<EOS
kb_server.port=${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}
kb_server.address=${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}
EOS

cat \
	>|"${SDA_MATLAB_CONF}/port.txt" \
	<<EOS
${MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_PORT}
EOS

exec ./run_main.sh "${MCR_HOME}"

exit 1
