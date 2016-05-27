#!/bin/bash

# source this file to get all your env exports before docker-compose up

# You'll need your licenses here, two if you're doing Artifactory HA
export ARTY_PRO_LICENSE1='changeme'
export ARTY_PRO_LICENSE2='changeme'

# Here's where you configure where your external DB if you want to
export ARTY_CHANGE_STORAGE='true'
export ARTY_DATABASE_TYPE='mysql'
export ARTY_DB_HOST='artydb'
export ARTY_DB_PORT='3306'
export ARTY_DB_NAME='artifactory'
export ARTY_DB_USER='artifactory'
export ARTY_DB_PASSWORD='p@ssw0rD'
export ARTY_JDBC_JAR_PATH='/Users/C62963/CloudStation/Software/jdbc/mysql-connector-java-5.1.33-bin.jar'

# REFACTOR, make DB independent. Do the init scripts directory trick probably.
export MARIA_ROOT_PASSWORD='@n0th3rp@ssw0rd'

# Set up HA here
export ARTY_IS_HA='true'
export ARTY_HA_CLUSTER_HOME='/mnt/artifactory/ha'
export ARTY_HA_MEMBERSHIP_PORT='10001'
export ARTY_HA_CLUSTER_TOKEN='changme'
