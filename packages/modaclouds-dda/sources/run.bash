#!/bin/bash

export MODACLOUDS_DDA_HOME="/opt/modaclouds-dda/lib"
export JAVA_HOME="/opt/mosaic-rt-jre-7"
export PATH="${JAVA_HOME}/bin:${PATH}"

cd -- "${MODACLOUDS_DDA_HOME}"
exec java -jar ./rsp-services-csparql-0.4.3.jar

exit 1
