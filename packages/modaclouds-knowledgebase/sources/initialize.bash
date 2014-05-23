#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

export MODACLOUDS_KNOWLEDGEBASE_HOME="/opt/@{package_name}"
FUSEKI_HOME="${MODACLOUDS_KNOWLEDGEBASE_HOME}/lib/jena-fuseki-@{jena_fuseki_version}"
export JAVA_HOME="/opt/mosaic-rt-jre-7"
export RUBY_HOME="/opt/mosaic-rt-ruby-v1.9"
export PATH="${JAVA_HOME}/bin:${PATH}"

test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}"

cd -- "${MODACLOUDS_KNOWLEDGEBASE_HOME}"

exec "${RUBY_HOME}/bin/ruby" "${FUSEKI_HOME}/s-put" \
		"http://${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}:${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}/modaclouds/kb/data" \
		default \
		./etc/ontology.ttl

exit 1
