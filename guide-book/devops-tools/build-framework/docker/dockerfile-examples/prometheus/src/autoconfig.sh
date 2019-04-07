#!/bin/bash

echo "AUTOCONFIG SCRIPT V: 2.0.0.2"
caller_identity="  get-caller-identity"
aws sts get-caller-identity


X_BAIKO_OFFLINE_TOKEN="${AUTO_CONF_BAIKO_TOKEN}"
REQUESTED_ENV="PROM_ENV=${AUTO_CONF_ENV}"
REQUESTED_NAMESPACE="${AUTOCONF_K8S_NAMESPACE}"
REQUESTED_SECRET="${AUTOCONF_K8S_SECTYPE}"


BAIKO_API_SERVER="https://baiko-server.services.traiana.com"
OFFLINE_TOKEN_ENDPOINT="/v1/auth/saml/api"
REFRESH_TOKEN_ENDPOINT="/v2/scope/public/token/refresh"
LIST_ENVIRONMENTS_ENDPOINT="/v2/scope/environment/env"

X_BAIKO_SERVER_AUTH=$(curl -s  -X POST "$BAIKO_API_SERVER$REFRESH_TOKEN_ENDPOINT" -H "accept: application/json" -H "content-type: application/json" -d "{ \"X-BAIKO-OFFLINE-TOKEN\": \"$X_BAIKO_OFFLINE_TOKEN\"}" | jq -r '.data."X-BAIKO-SERVER-AUTH"')

baikoEnvs=$(curl -s -X GET "$BAIKO_API_SERVER$LIST_ENVIRONMENTS_ENDPOINT" -H "X-BAIKO-SERVER-AUTH: $X_BAIKO_SERVER_AUTH" | jq --arg v "$REQUESTED_ENV" -c '[.data[]
    | select(.envDescription | contains($v))?
    | {envName:.envName, envProfile: .envProfile, dnsName: .dnsName, kubeconfig: .kubeconfig}]')

_internalReportFormatter="%15.15s\t%10.10s\t%40.40s\t%40.40s\t%10.10s\t%10.10s\n"

#File Output Configs
__internalWrkFolderRoot=run/$(date +"%Y%m%d-%H%M%S")

__kubernetesApiCertsDestinationFile="${__internalWrkFolderRoot}/secrets"
__exportKubernetesConfigDestinationFile="${__internalWrkFolderRoot}/kube_configs";
__templatePrometheusConfig_variablesFile="tmp/promAutoConf"
__templatePrometheusConfig_outputFile="outputs"

__templatePrometheusConfig_templateSrcsFile="*.template"
__templatePrometheusConfig_templateSrcFile="tmp/promAutoConf/prom_kube.template"
finalResultFile="prom/conf.yaml"



mkdir -p {${__templatePrometheusConfig_outputFile},${__templatePrometheusConfig_variablesFile}}
mkdir -p {${__kubernetesApiCertsDestinationFile},${__exportKubernetesConfigDestinationFile},${__templatePrometheusConfig_variablesFile},${__templatePrometheusConfig_outputFile}}

find templates/ -name "${__templatePrometheusConfig_templateSrcsFile}" -type f -print0 | sort -z | xargs -0 cat > ${__templatePrometheusConfig_templateSrcFile}

function reportHeader(){
    printf ${_internalReportFormatter} "  Env name     " "  profile " "              cluster name              " "                api uri                 " "  action  " "  status  "
    printf ${_internalReportFormatter} "---------------" "----------" "----------------------------------------" "----------------------------------------" "----------" "----------"
}

function reportActionResults(){
    local envName=$1;local baikoEnvProfile=$2;local kubernetesClusterName=$3;local kubernetesApiServer=$4;local actionStatus=$5;local actionStatus=$6;
    printf ${_internalReportFormatter} "$1" "$2" "$3" "$4" "$5" "$6"
}

function extractKubernetesApiCerts(){
    local baikoEnvName=$1; local kubernetesConfig=$2; local kubernetesApiCertsDestinationFile="${__kubernetesApiCertsDestinationFile}/${baikoEnvName}"
    echo "$(echo "$kubernetesConfig" | sed 's/[[:space:]]//g' | grep -w certificate-authority-data | cut -f2-3 -d ":" | base64 --decode)" >${kubernetesApiCertsDestinationFile}_ca.pem
    echo "$(echo "$kubernetesConfig" | sed 's/[[:space:]]//g' | grep -w client-certificate-data | cut -f2-3 -d ":" | base64 --decode)" >${kubernetesApiCertsDestinationFile}_client.pem
    echo "$(echo "$kubernetesConfig" | sed 's/[[:space:]]//g' | grep -w client-key-data | cut -f2-3 -d ":" | base64 --decode)" >${kubernetesApiCertsDestinationFile}_key.pem
}

function exportKubernetesConfigFile(){
    local baikoEnvName=$1; local kubernetesConfig=$2;local exportKubernetesConfigDestinationFile="${__exportKubernetesConfigDestinationFile}/${baikoEnvName}_conf.yaml"
    echo "$kubernetesConfig" > ${exportKubernetesConfigDestinationFile}
}


function templatePrometheusConfig(){
    # return codes: 0 - OK, 21- cannot resolve host; 22- cannot connect to server; 23- cannot get valid API bearer_token; 24- failed to template the config
    local AWS_ACCOUNT_ALIAS=$(aws iam list-account-aliases | jq -r '.AccountAliases|.[0]')
    local BAIKO_ENV_NAME=$1;local baikoEnvProfile=$2;local KUBERNETES_CLUSTER_NAME=$3;local kubernetesApiServer=$4; local kubernetesApiUri=$5; local kubernetesConfig=$6;
    local _variablesFile="${__templatePrometheusConfig_variablesFile}/${BAIKO_ENV_NAME}_variables.txt";
    local _outputFile="${__templatePrometheusConfig_outputFile}/${BAIKO_ENV_NAME}_promcfg.yaml";
    local kubernetesApiCertsDestinationFile="${__kubernetesApiCertsDestinationFile}/${BAIKO_ENV_NAME}"
    local exportKubernetesConfigDestinationFile="${__exportKubernetesConfigDestinationFile}/${baikoEnvName}_conf.yaml"

    echo "$kubernetesConfig" > ${exportKubernetesConfigDestinationFile}
    host ${kubernetesApiServer} > /dev/null 2>&1 || return 21;
    local secretName=$(kubectl --insecure-skip-tls-verify --kubeconfig ${exportKubernetesConfigDestinationFile} get secrets  -n ${REQUESTED_NAMESPACE} | grep ${REQUESTED_SECRET} | awk 'NR==1{print $1}')
    bearer_token=$(kubectl --insecure-skip-tls-verify --kubeconfig ${exportKubernetesConfigDestinationFile} describe secret -n ${REQUESTED_NAMESPACE} "${secretName}" | grep -E '^token' | cut -f2 -d ':' | tr -d '\t' | sed "s/ //g") || return 23
    echo "CLUSTER ${KUBERNETES_CLUSTER_NAME} uses secret name: ${secretName}"
    cat >${_variablesFile}<<EOL
AWS_ACCOUNT_ALIAS=${AWS_ACCOUNT_ALIAS}
BAIKO_ENV_PROFILE=${BAIKO_ENV_NAME}
CLUSTER_API_SERVER_URI=${kubernetesApiUri}
CLUSTER_API_SERVER=${kubernetesApiServer}
CLUSTER_NAME=${KUBERNETES_CLUSTER_NAME}
CLUSTER_BEARER_TOKEN=${bearer_token}
EOL

    sh templater.sh ${__templatePrometheusConfig_templateSrcFile} -f ${_variablesFile} > ${_outputFile} || return 25;

    return 0;
}


function retrieveKubernetesCtlConfig(){
    reportHeader
    for baikoEnv in $(echo ${baikoEnvs} | jq -c '.[]'); do
        local baikoEnvName=$(echo ${baikoEnv} | jq --raw-output '.envName')
        local baikoEnvProfile=$(echo ${baikoEnv} | jq --raw-output '.envProfile')
        local kubernetesConfig=$(echo ${baikoEnv} | jq --raw-output '.kubeconfig' | base64 --decode )
        local kubernetesClusterName=$(echo "$kubernetesConfig" | sed 's/[[:space:]]//g' | grep -w cluster | cut -f2-3 -d ":" | sed -n 2p)
        local kubernetesApiUri=$(echo "$kubernetesConfig" | sed 's/[[:space:]]//g' | grep -w server | cut -f2-3 -d ":")
        local kubernetesApiServer=$(echo "$kubernetesApiUri" | cut -f3 -d "/")

        exportKubernetesConfigFile ${baikoEnvName} "${kubernetesConfig}"
        templatePrometheusConfig ${baikoEnvName} ${baikoEnvProfile} ${kubernetesClusterName} ${kubernetesApiServer} ${kubernetesApiUri} "${kubernetesConfig}"; local result=$?
        reportActionResults ${baikoEnvName} ${baikoEnvProfile} ${kubernetesClusterName} ${kubernetesApiServer} "template" "${result}";

    done
}

function consolidateResultsFiles(){
    find templates/ -name "*-headers.yaml" -type f -print0 | sort -z | xargs -0 cat >> ${finalResultFile}
    find outputs/ -name "*.yaml" -type f -print0 | sort -z | xargs -0 cat >> ${finalResultFile}
    find templates/ -name "*-footers.yaml" -type f -print0 | sort -z | xargs -0 cat >> ${finalResultFile}
}

retrieveKubernetesCtlConfig
consolidateResultsFiles

cat ${finalResultFile}