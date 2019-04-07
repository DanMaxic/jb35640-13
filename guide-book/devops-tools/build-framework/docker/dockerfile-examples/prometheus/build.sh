#!/usr/bin/env bash

DOCKER_IMAGE_NAME='sre-inf-mgmt-prometheus'
DOCKER_DEFAULT_TAG='latest'
DOCKER_REPO_URI='550959330073.dkr.ecr.eu-west-1.amazonaws.com'

DOCK_BUILD_ARG_SRC_APP_CONFIG_FILE='s3://sre-inf-mgmt-tmp/prometheus.yml'
DOCK_BUILD_ARG_DST_APP_CONFIG_FILE='/prom/conf.yml'
DOCK_BUILD_ARG_WEB_LISTEN_PORT=9090
DOCK_BUILD_ARG_WEB_USER_ASSETS='/prom/embedded-portal'
DOCK_BUILD_ARG_STORAGE_TSDB_PATH='/data'
DOCK_BUILD_ARG_QUERY_LOOKBACK_DELTA='60m'
DOCK_BUILD_ARG_QUERY_MAX_CONCURRENCY='512'
DOCK_BUILD_ARG_QUERY_TIMEOUT='5m'
DOCK_BUILD_ARG_STORAGE_TSDB_RETENTION='15d'
DOCK_BUILD_ARG_LOG_LEVEL='info'

DOCKER_BUILD_ARGS='--rm --compress'
DOCKER_BUILD_QUIET=false
TAG_IMAGE_BUILT=true


DYNAMIC_DOCKER_ARGS=`( set -o posix ; set ) | grep DOCK_BUILD_ARG_ | tr '\n' ','| tr -d "\'"`
docker_args_collector=''
if [ ! -z "${DYNAMIC_DOCKER_ARGS}" ]; then
  OLDIFS=$IFS; IFS=',';
  echo "FOUND FOLLOWING DOCKER BUILD PARAMS"
  for docker_arg in ${DYNAMIC_DOCKER_ARGS}; do
    IFS=$OLDIFS; echo "    ${docker_arg}";docker_args_collector="${docker_args_collector} --build-arg ${docker_arg}";
  done
fi

if [[ ${DOCKER_BUILD_QUIET} = true ]]; then DOCKER_BUILD_ARGS="${DOCKER_BUILD_ARGS} --quiet"; fi


docker build -t ${DOCKER_IMAGE_NAME} ${docker_args_collector}  ${DOCKER_BUILD_ARGS} .
