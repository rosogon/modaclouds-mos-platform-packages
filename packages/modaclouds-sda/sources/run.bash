#!/bin/bash

export MODACLOUDS_SDA_HOME="/opt/modaclouds-sda/lib"
export MATHLAB_MCR="/opt/modaclouds-rt-matlab-mcr-r2013a/v81"
export JAVA_HOME="/opt/mosaic-rt-jre-7"
export PATH="${JAVA_HOME}/bin:${PATH}"

cd -- "${MODACLOUDS_SDA_HOME}"
exec ./run_main.sh "${MATHLAB_MCR}"

exit 1
