#!/bin/bash

S3_PULLS_RETRIES=10
S3_PULLS_INTERVALS=10

echo "#############################################"

echo "AUTO_CONF_ENV: ${AUTO_CONF_ENV}"
echo "AUTO_CONF_BAIKO_TOKEN: ${AUTO_CONF_BAIKO_TOKEN}"
echo "SRC_APP_CONFIG_FILE: ${SRC_APP_CONFIG_FILE}"
echo "DST_APP_CONFIG_FILE: ${DST_APP_CONFIG_FILE}"
echo "WEB_LISTEN_PORT: ${WEB_LISTEN_PORT}"
echo "WEB_USER_ASSETS: ${WEB_USER_ASSETS}"
echo "STORAGE_TSDB_PATH: ${STORAGE_TSDB_PATH}"
echo "QUERY_LOOKBACK_DELTA: ${QUERY_LOOKBACK_DELTA}"
echo "QUERY_MAX_CONCURRENCY: ${QUERY_MAX_CONCURRENCY}"
echo "QUERY_TIMEOUT: ${QUERY_TIMEOUT}"
echo "STORAGE_TSDB_RETENTION: ${STORAGE_TSDB_RETENTION}"
echo "LOG_LEVEL: ${LOG_LEVEL}"
echo "#############################################"

#
echo "############################################################"
if [[ -z "${AUTO_CONF_PULL_CONFIG_FROM_S3}" ]]; then
    echo "Instructed to RUN AUTO CONF";
    sh autoconfig.sh;
    echo "AUTO CONF FINISHED";

else
    echo "Instructed to download conf from S3";
    echo "SOURCE S3:${SRC_APP_CONFIG_FILE}";
    echo "DST file: ${DST_APP_CONFIG_FILE}"
    n=0
    until [ ${n} -ge ${S3_PULLS_RETRIES} ]
    do
        aws s3 cp ${SRC_APP_CONFIG_FILE} ${DST_APP_CONFIG_FILE} && break
        n=$[$n+1]
        sleep ${S3_PULLS_INTERVALS}
    done

    if [ $? -eq 0 ]; then echo "PULL FROM S3 FINISHED"; else echo "PULL FROM S3 FAILED, EXITING"; exit 2; fi

fi

echo "############################################################"

echo "BOOTING UP PROMETHEUS"
./prom/prometheus   --config.file="${DST_APP_CONFIG_FILE}" \
                    --web.listen-address="0.0.0.0:${WEB_LISTEN_PORT}" \
                    --web.user-assets="${WEB_USER_ASSETS}" \
                    --query.max-concurrency=${QUERY_MAX_CONCURRENCY} \
                    --web.enable-lifecycle \
                    --web.enable-admin-api \
                    --storage.tsdb.no-lockfile \
                    --storage.tsdb.path="${STORAGE_TSDB_PATH}" \
                    --query.lookback-delta=${QUERY_LOOKBACK_DELTA} \
                    --query.timeout=${QUERY_TIMEOUT} \
                    --storage.tsdb.retention=${STORAGE_TSDB_RETENTION} \
                    --log.level=${LOG_LEVEL} \

status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start ./prometheus/prometheus: $status"
  exit $status
fi

echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
#
#echo "starting pushgateway"
## Start the second process
#./prometheus/pushgateway &
#status=$?
#if [ $status -ne 0 ]; then
#  echo "Failed to start ./prometheus/pushgateway: $status"
#  exit $status
#fi
#echo "starting prom3"
#while sleep 60; do
#  ps aux |grep prometheus |grep -q -v grep
#  PROCESS_1_STATUS=$?
#  ps aux |grep pushgateway |grep -q -v grep
#  PROCESS_2_STATUS=$?
#  # If the greps above find anything, they exit with 0 status
#  # If they are not both 0, then something is wrong
#  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
#    echo "One of the processes has already exited."
#    exit -1
#  fi
#done