#!/bin/bash
S3_PULLS_RETRIES=10
S3_PULLS_INTERVALS=10

echo "#############################################"
echo "############ START UP VARIABLES        ######"
echo "GF_INSTALL_PLUGINS: ${GF_INSTALL_PLUGINS}"
echo "SRC_APP_CONFIG_FILE: ${SRC_APP_CONFIG_FILE}"


echo "GF_PATHS_CONFIG: ${GF_PATHS_CONFIG}"
echo "GF_PATHS_DATA: ${GF_PATHS_DATA}"
echo "GF_PATHS_HOME: ${GF_PATHS_HOME}"
echo "GF_PATHS_LOGS: ${GF_PATHS_LOGS}"
echo "GF_PATHS_PLUGINS: ${GF_PATHS_PLUGINS}"
echo "GF_PATHS_PROVISIONING: ${GF_PATHS_PROVISIONING}"
echo "#############################################"
set
echo "#############################################"

function preperImage(){
  mkdir -p  "$GF_PATHS_DATA" \
            "$GF_PATHS_HOME" \
            "$GF_PATHS_LOGS" \
            "$GF_PATHS_PLUGINS" \
            "$GF_PATHS_PROVISIONING" \
            "$GF_DASHBOARDS_JSON_PATH"
}
function installPlugIns(){
  echo "INSTALLING PLUGINS FILES...";
  if [ ! -z "$GF_INSTALL_PLUGINS" ]; then
    echo "    INSTALLING PLUGIN ${plugin} to ${GF_PATHS_PLUGINS}";
    ./usr/sbin/grafana-cli --pluginsDir "${GF_INSTALL_PLUGINS}" plugins install ${plugin};
    ./usr/sbin/grafana-cli plugins update-all

      OLDIFS=$IFS ; IFS=',';
      for plugin in ${GF_INSTALL_PLUGINS}; do
          IFS=$OLDIFS;
      done;
  fi

  installLogzIOPlugIns

}

function installLogzIOPlugIns(){
  echo "PULL LOGZIO PLUGINS";
  git clone https://github.com/logzio/grafana-logzio-datasource.git /tmp/logzio
  mkdir -p ${GF_PATHS_PLUGINS}/logzio/
  cp -R  /tmp/logzio/* ${GF_PATHS_PLUGINS}/logzio/
  rm -rf  /tmp/logzio
}

function pullS3Configs(){
  if [ ! -z "$SRC_APP_CONFIG_FILE" ]; then
    echo "PULLING CONFIG FILES FROM S3";
    n=0
    until [ ${n} -ge ${S3_PULLS_RETRIES} ]
    do
        aws s3 cp ${SRC_APP_CONFIG_FILE} ${DST_APP_CONFIG_FILE} && break
        n=$[$n+1]
        sleep ${S3_PULLS_INTERVALS}
    done
    if [ $? -eq 0 ]; then echo "PULL CONFIG S3 FINISHED"; else echo "PULL FROM S3 FAILED, EXITING"; exit 2; fi
  fi
}

function startGrafana(){
  # Start the first process
  echo "STARTING GRAFANA..."
  exec grafana-server                                         \
    --homepath="$GF_PATHS_HOME"                               \
    --config="$GF_PATHS_CONFIG"

  status=$?
  if [ $status -ne 0 ]; then
    echo "Failed to start .grafana: $status"
    exit $status
  fi
}

preperImage
installPlugIns
pullS3Configs
startGrafana
