#!/bin/bash

shopt -s nocasematch
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ -z "$ARTY_PRO_LICENSE" ]; then
  printf "${ORANGE}No ARTY_PRO_LICENSE environment variable set. You will be required to set your license using the Artifactory web console.\n${NC}"
else
  printf "${GREEN}Artifactory pro license successfully set.\n${NC}"
  echo "$ARTY_PRO_LICENSE" > $ARTIFACTORY_HOME/etc/artifactory.lic
fi

arty_storage=""

if [ "$ARTY_CHANGE_STORAGE" == "true" ]; then

  need_params=false
  [ -z "$ARTY_DATABASE_TYPE" ] && { printf "${RED}Need to set ARTY_DATABASE_TYPE to to mysql | mssql | oracle | postgres\n${NC}"; need_params=true; }
  [ -z "$ARTY_DB_HOST" ] && { printf "${RED}Need to set ARTY_DB_HOST\n${NC}"; need_params=true; }
  [ -z "$ARTY_DB_NAME" ] && { printf "${RED}Need to set ARTY_DB_NAME\n${NC}"; need_params=true; }
  [ -z "$ARTY_DB_USER" ] && { printf "${RED}Need to set ARTY_DB_USER\n${NC}"; need_params=true; }
  [ -z "$ARTY_DB_USER" ] && { printf "${RED}Need to set ARTY_DB_USER\n${NC}"; need_params=true; }
  [ -z "$ARTY_DB_PASSWORD" ] && { printf "${RED}Need to set ARTY_DB_PASSWORD\n${NC}"; need_params=true; }

  if [ need_params == true ]; then
    printf "${RED}Error in environment variable configuration. Exiting.\n${NC}"
    exit 1
  fi

  arty_storage+="# Storage Config\n"
  arty_storage+="type=$ARTY_DATABASE_TYPE\n"

  case "$ARTY_DATABASE_TYPE" in
    'mysql')
    arty_storage+="driver=com.mysql.jdbc.Driver\n"
    arty_storage+="url=jdbc:mysql://$ARTY_DB_HOST:$ARTY_DB_PORT/$ARTY_DB_NAME?characterEncoding=UTF-8&elideSetAutoCommits=true&user=$ARTY_DB_USER&password=$ARTY_DB_PASSWORD\n"
    arty_storage+="username=$ARTY_DB_USER\n"
    arty_storage+="password=$ARTY_DB_PASSWORD\n"
    ;;
    'mssql')
    arty_storage+="driver=com.microsoft.sqlserver.jdbc.SQLServerDriver\n"
    arty_storage+="url=jdbc:sqlserver://$ARTY_DB_HOST:$ARTY_DB_PORT;databaseName=$ARTY_DB_NAME;sendStringParametersAsUnicode=false;applicationName=Artifactory Binary Repository\n"
    arty_storage+="username=$ARTY_DB_USER\n"
    arty_storage+="password=$ARTY_DB_PASSWORD\n"
    ;;
    'oracle')
    arty_storage+="driver=oracle.jdbc.OracleDriver\n"
    arty_storage+="url=jdbc:oracle:thin:@$ARTY_DB_HOST:$ARTY_DB_PORT:ORCL"
    arty_storage+="username=$ARTY_DB_USER\n"
    arty_storage+="password=$ARTY_DB_PASSWORD\n"
    ;;
    'postgres')
    arty_storage+="driver=org.postgresql.Driver\n"
    arty_storage+="url=jdbc:postgresql://$ARTY_DB_HOST:$ARTY_DB_PORT/$ARTY_DB_NAME"
    arty_storage+="username=$ARTY_DB_USER\n"
    arty_storage+="password=$ARTY_DB_PASSWORD\n"
    ;;
  esac

  if [ "$ARTY_BINARY_PROVIDER_TYPE" ]; then
    arty_storage+="binary.provider.type=$ARTY_BINARY_PROVIDER_TYPE\n"
  fi

  printf "${GREEN}Artifactory storage successfully configured.\n${NC}"
  echo -e $arty_storage > $ARTIFACTORY_HOME/etc/storage.properties

else
  printf "${ORANGE}No environment variables for Artifactory storage configuration provided. Aritfactory will use local defaults.\n${NC}"
fi

if [ "$ARTY_IS_HA" == "true" ]; then
  need_params=false
  [ -z "$ARTY_HA_IS_PRIMARY" ] && { printf "${RED}Need to set ARTY_HA_IS_PRIMARY to to true or false\n${NC}"; need_params=true; }
  [ -z "$ARTY_HA_CLUSTER_HOME" ] && { printf "${RED}Need to set ARTY_HA_CLUSTER_HOME\n${NC}"; need_params=true; }
  [ -z "$ARTY_HA_MEMBERSHIP_PORT" ] && { printf "${RED}Need to set ARTY_HA_MEMBERSHIP_PORT\n${NC}"; need_params=true; }
  [ -z "$ARTY_HA_CLUSTER_TOKEN" ] && { printf "${RED}Need to set ARTY_HA_CLUSTER_TOKEN\n${NC}"; need_params=true; }

  if [ need_params == true ]; then
    printf "${RED}Error in HA node configuration. Exiting.\n${NC}"
    exit 1
  fi

  arty_ha=""
  ip_address=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

  arty_ha+="# HA Node Config\n"
  arty_ha+="node.id=$HOSTNAME\n"
  arty_ha+="cluster.home=$ARTY_HA_CLUSTER_HOME\n"
  arty_ha+="context.url=http://$ip_address:8081/artifactory\n"
  arty_ha+="membership.port=$ARTY_HA_MEMBERSHIP_PORT\n"

  if [ "$ARTY_HA_IS_PRIMARY" == "true" ]; then
    arty_ha+="primary=true\n"
  else
    arty_ha+="primary=false\n"
  fi

  printf "${GREEN}Artifactory HA node settings successfully configured.\n${NC}"
  echo -e $arty_ha > $ARTIFACTORY_HOME/etc/ha-node.properties

  # sec_token=$(date +%s | shasum5.16 | base64 | head -c 32 ; echo)
  arty_cluster=""
  arty_cluster+="# Cluster Config\n"
  arty_cluster+="security.token=$ARTY_HA_CLUSTER_TOKEN"

  mkdir $ARTY_HA_CLUSTER_HOME/ha-etc

  printf "${GREEN}Artifactory cluster settings successfully configured.\n${NC}"
  echo -e $arty_cluster > $ARTY_HA_CLUSTER_HOME/ha-etc/cluster.properties
  echo -e $arty_storage > $ARTY_HA_CLUSTER_HOME/ha-etc/storage.properties
else
  printf "${ORANGE}No environment variables for Artifactory HA configuration provided. Aritfactory run as a single, standalone instance.\n${NC}"
fi

exec "$@"
# for f in /docker-entrypoint-arty.d/*; do
#     case "$f" in
#       *.sh)     echo "$0: running $f"; . "$f" ;;
#       *)        echo "$0: ignoring $f" ;;
#     esac
#     echo
# done
