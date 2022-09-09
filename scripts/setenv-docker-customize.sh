﻿#!/bin/bash -eu
#
# This file is part of the Meeds project (https://meeds.io/).
# Copyright (C) 2020 Meeds Association
# contact@meeds.io
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# You should have received a copy of the GNU Lesser General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# -----------------------------------------------------------------------------
#
# Settings customization
#
# -----------------------------------------------------------------------------
# This file contains customizations related to Docker environment.
# -----------------------------------------------------------------------------

replace_in_file() {
  local _tmpFile=$(mktemp /tmp/replace.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
  mv $1 ${_tmpFile}
  sed "s|$2|$3|g" ${_tmpFile} > $1
  rm ${_tmpFile}
}

# $1 : the full line content to insert at the end of Meeds configuration file
add_in_meeds_configuration() {
  local MEEDS_CONFIG_FILE="/etc/meeds/docker.properties"
  local P1="$1"
  if [ ! -f ${MEEDS_CONFIG_FILE} ]; then
    echo "Creating Meeds Docker configuration file [${MEEDS_CONFIG_FILE}]"
    touch ${MEEDS_CONFIG_FILE}
    if [ $? != 0 ]; then
      echo "Problem during Meeds Docker configuration file creation, startup aborted !"
      exit 1
    fi
  fi
  # Ensure the content will be added on a new line
  tail -c1 ${MEEDS_CONFIG_FILE}  | read -r _ || echo >> ${MEEDS_CONFIG_FILE}
  echo "${P1}" >> ${MEEDS_CONFIG_FILE}
}

# -----------------------------------------------------------------------------
# Check configuration variables and add default values when needed
# -----------------------------------------------------------------------------
set +u		# DEACTIVATE unbound variable check

# revert Tomcat umask change (before Tomcat 8.5 = 0022 / starting from Tomcat 8.5 = 0027)
# see https://tomcat.apache.org/tomcat-8.5-doc/changelog.html#Tomcat_8.5.0_(markt)
[ -z "${MEEDS_FILE_UMASK}" ] && UMASK="0022" || UMASK="${MEEDS_FILE_UMASK}" 

[ -z "${MEEDS_PROXY_VHOST}" ] && MEEDS_PROXY_VHOST="localhost"
[ -z "${MEEDS_PROXY_SSL}" ] && MEEDS_PROXY_SSL="false"
[ -z "${MEEDS_PROXY_PORT}" ] && {
  case "${MEEDS_PROXY_SSL}" in 
    true) MEEDS_PROXY_PORT="443";;
    false) MEEDS_PROXY_PORT="8080";;
    *) MEEDS_PROXY_PORT="8080";;
  esac
}
[ -z "${MEEDS_DATA_DIR}" ] && MEEDS_DATA_DIR="/srv/meeds"
[ -z "${MEEDS_JCR_STORAGE_DIR}" ] && MEEDS_JCR_STORAGE_DIR="${MEEDS_DATA_DIR}/jcr/values"
[ -z "${MEEDS_FILE_STORAGE_DIR}" ] && MEEDS_FILE_STORAGE_DIR="${MEEDS_DATA_DIR}/files"
[ -z "${MEEDS_FILE_STORAGE_RETENTION}" ] && MEEDS_FILE_STORAGE_RETENTION="30"

[ -z "${MEEDS_DB_TIMEOUT}" ] && MEEDS_DB_TIMEOUT="60"
[ -z "${MEEDS_DB_TYPE}" ] && MEEDS_DB_TYPE="hsqldb"
case "${MEEDS_DB_TYPE}" in
  hsqldb)
    echo "################################################################################"
    echo "# WARNING: you are using HSQLDB which is not recommanded for production purpose."
    echo "################################################################################"
    sleep 2
    ;;
  mysql)
    [ -z "${MEEDS_DB_NAME}" ] && MEEDS_DB_NAME="meeds"
    [ -z "${MEEDS_DB_USER}" ] && MEEDS_DB_USER="meeds"
    [ -z "${MEEDS_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with MEEDS_DB_PASSWORD environment variable"; exit 1;}
    [ -z "${MEEDS_DB_HOST}" ] && MEEDS_DB_HOST="db"
    [ -z "${MEEDS_DB_PORT}" ] && MEEDS_DB_PORT="3306"
    [ -z "${MEEDS_DB_MYSQL_USE_SSL}" ] && MEEDS_DB_MYSQL_USE_SSL="false"
    ;;
  pgsql|postgres|postgresql)
    [ -z "${MEEDS_DB_NAME}" ] && MEEDS_DB_NAME="meeds"
    [ -z "${MEEDS_DB_USER}" ] && MEEDS_DB_USER="meeds"
    [ -z "${MEEDS_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with MEEDS_DB_PASSWORD environment variable"; exit 1;}
    [ -z "${MEEDS_DB_HOST}" ] && MEEDS_DB_HOST="db"
    [ -z "${MEEDS_DB_PORT}" ] && MEEDS_DB_PORT="5432"
    ;;
  *)
    echo "ERROR: you must provide a supported database type with MEEDS_DB_TYPE environment variable (current value is '${MEEDS_DB_TYPE}')"
    echo "ERROR: supported database types are :"
    echo "ERROR: HSQLDB     (MEEDS_DB_TYPE = hsqldb) (default)"
    echo "ERROR: MySQL      (MEEDS_DB_TYPE = mysql)"
    echo "ERROR: Postgresql (MEEDS_DB_TYPE = pgsql)"
    exit 1;;
esac
[ -z "${MEEDS_DB_POOL_IDM_INIT_SIZE}" ] && MEEDS_DB_POOL_IDM_INIT_SIZE="5"
[ -z "${MEEDS_DB_POOL_IDM_MAX_SIZE}" ] && MEEDS_DB_POOL_IDM_MAX_SIZE="20"
[ -z "${MEEDS_DB_POOL_JCR_INIT_SIZE}" ] && MEEDS_DB_POOL_JCR_INIT_SIZE="5"
[ -z "${MEEDS_DB_POOL_JCR_MAX_SIZE}" ] && MEEDS_DB_POOL_JCR_MAX_SIZE="20"
[ -z "${MEEDS_DB_POOL_JPA_INIT_SIZE}" ] && MEEDS_DB_POOL_JPA_INIT_SIZE="5"
[ -z "${MEEDS_DB_POOL_JPA_MAX_SIZE}" ] && MEEDS_DB_POOL_JPA_MAX_SIZE="20"

[ -z "${MEEDS_UPLOAD_MAX_FILE_SIZE}" ] && MEEDS_UPLOAD_MAX_FILE_SIZE="200"

[ -z "${MEEDS_HTTP_THREAD_MIN}" ] && MEEDS_HTTP_THREAD_MIN="10"
[ -z "${MEEDS_HTTP_THREAD_MAX}" ] && MEEDS_HTTP_THREAD_MAX="200"

[ -z "${MEEDS_MAIL_FROM}" ] && MEEDS_MAIL_FROM="noreply@example.com"
[ -z "${MEEDS_MAIL_SMTP_HOST}" ] && MEEDS_MAIL_SMTP_HOST="localhost"
[ -z "${MEEDS_MAIL_SMTP_PORT}" ] && MEEDS_MAIL_SMTP_PORT="25"
[ -z "${MEEDS_MAIL_SMTP_STARTTLS}" ] && MEEDS_MAIL_SMTP_STARTTLS="false"
[ -z "${MEEDS_MAIL_SMTP_USERNAME}" ] && MEEDS_MAIL_SMTP_USERNAME="-"
[ -z "${MEEDS_MAIL_SMTP_PASSWORD}" ] && MEEDS_MAIL_SMTP_PASSWORD="-"

[ -z "${MEEDS_JVM_LOG_GC_ENABLED}" ] && MEEDS_JVM_LOG_GC_ENABLED="false"

[ -z "${MEEDS_JMX_ENABLED}" ] && MEEDS_JMX_ENABLED="true"
[ -z "${MEEDS_JMX_RMI_REGISTRY_PORT}" ] && MEEDS_JMX_RMI_REGISTRY_PORT="10001"
[ -z "${MEEDS_JMX_RMI_SERVER_PORT}" ] && MEEDS_JMX_RMI_SERVER_PORT="10002"
[ -z "${MEEDS_JMX_RMI_SERVER_HOSTNAME}" ] && MEEDS_JMX_RMI_SERVER_HOSTNAME="localhost"
[ -z "${MEEDS_JMX_USERNAME}" ] && MEEDS_JMX_USERNAME="-"
[ -z "${MEEDS_JMX_PASSWORD}" ] && MEEDS_JMX_PASSWORD="-"

[ -z "${MEEDS_ACCESS_LOG_ENABLED}" ] && MEEDS_ACCESS_LOG_ENABLED="false"

[ -z "${MEEDS_ES_TIMEOUT}" ] && MEEDS_ES_TIMEOUT="60"
[ -z "${MEEDS_ES_SCHEME}" ] && MEEDS_ES_SCHEME="http"
[ -z "${MEEDS_ES_HOST}" ] && MEEDS_ES_HOST="localhost"
[ -z "${MEEDS_ES_PORT}" ] && MEEDS_ES_PORT="9200"
MEEDS_ES_URL="${MEEDS_ES_SCHEME}://${MEEDS_ES_HOST}:${MEEDS_ES_PORT}"
[ -z "${MEEDS_ES_USERNAME}" ] && MEEDS_ES_USERNAME="-"
[ -z "${MEEDS_ES_PASSWORD}" ] && MEEDS_ES_PASSWORD="-"
[ -z "${MEEDS_ES_INDEX_REPLICA_NB}" ] && MEEDS_ES_INDEX_REPLICA_NB="1"
[ -z "${MEEDS_ES_INDEX_SHARD_NB}" ] && MEEDS_ES_INDEX_SHARD_NB="5"


[ -z "${MEEDS_LDAP_POOL_TIMEOUT}" ] && MEEDS_LDAP_POOL_TIMEOUT="60000"
[ -z "${MEEDS_LDAP_POOL_MAX_SIZE}" ] && MEEDS_LDAP_POOL_MAX_SIZE="100"

[ -z "${MEEDS_JODCONVERTER_PORTS}" ] && MEEDS_JODCONVERTER_PORTS="2002"

[ -z "${MEEDS_REWARDS_WALLET_ADMIN_KEY}" ] && MEEDS_REWARDS_WALLET_ADMIN_KEY="changeThisKey"
[ -z "${MEEDS_REWARDS_WALLET_ACCESS_PERMISSION}" ] && MEEDS_REWARDS_WALLET_ACCESS_PERMISSION="/platform/users"
[ -z "${MEEDS_REWARDS_WALLET_NETWORK_ID}" ] && MEEDS_REWARDS_WALLET_NETWORK_ID="1"
[ -z "${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP}" ] && MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP="https://mainnet.infura.io/v3/a1ac85aea9ce4be88e9e87dad7c01d40"
[ -z "${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET}" ] && MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET="wss://mainnet.infura.io/ws/v3/a1ac85aea9ce4be88e9e87dad7c01d40"
[ -z "${MEEDS_REWARDS_WALLET_TOKEN_ADDRESS}" ] && MEEDS_REWARDS_WALLET_TOKEN_ADDRESS="0xc76987d43b77c45d51653b6eb110b9174acce8fb"

[ -z "${MEEDS_ADDONS_CONFLICT_MODE}" ] && MEEDS_ADDONS_CONFLICT_MODE=""
[ -z "${MEEDS_ADDONS_NOCOMPAT_MODE}" ] && MEEDS_ADDONS_NOCOMPAT_MODE="false"

[ -z "${MEEDS_CLUSTER_NODE_NAME}" ] && MEEDS_CLUSTER_NODE_NAME=""

[ -z "${MEEDS_TOKEN_REMEMBERME_EXPIRATION_VALUE}" ] && MEEDS_TOKEN_REMEMBERME_EXPIRATION_VALUE="7"
[ -z "${MEEDS_TOKEN_REMEMBERME_EXPIRATION_UNIT}" ] && MEEDS_TOKEN_REMEMBERME_EXPIRATION_UNIT="DAY"


[ -z "${MEEDS_GZIP_ENABLED}" ] && MEEDS_GZIP_ENABLED="true"

# Mapping with sentenv.sh 
[ ! -z "${MEEDS_JVM_SIZE_MAX}" ] && EXO_JVM_SIZE_MAX="${MEEDS_JVM_SIZE_MAX}"
[ ! -z "${MEEDS_JVM_SIZE_MIN}" ] && EXO_JVM_SIZE_MIN="${MEEDS_JVM_SIZE_MIN}"

# Logback Debug logger
[ -z "${MEEDS_LOGBACK_LOGGERS_DEBUG}" ] && MEEDS_LOGBACK_LOGGERS_DEBUG=""

set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/meeds/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else


  # Jcr storage configuration
  add_in_meeds_configuration "exo.jcr.storage.data.dir=${MEEDS_JCR_STORAGE_DIR}"

  # File storage configuration
  add_in_meeds_configuration "# File storage configuration"
  add_in_meeds_configuration "exo.files.binaries.storage.type=fs"
  add_in_meeds_configuration "exo.files.storage.dir=${MEEDS_FILE_STORAGE_DIR}"
  add_in_meeds_configuration "exo.commons.FileStorageCleanJob.retention-time=${MEEDS_FILE_STORAGE_RETENTION}"

  # Database configuration
  case "${MEEDS_DB_TYPE}" in
    hsqldb)
      cat /opt/meeds/conf/server-hsqldb.xml > /opt/meeds/conf/server.xml
      ;;
    mysql)
      cat /opt/meeds/conf/server-mysql.xml > /opt/meeds/conf/server.xml
      replace_in_file /opt/meeds/conf/server.xml "jdbc:mysql://localhost:3306/plf?autoReconnect=true" "jdbc:mysql://${MEEDS_DB_HOST}:${MEEDS_DB_PORT}/${MEEDS_DB_NAME}?autoReconnect=true\&amp;useSSL=${MEEDS_DB_MYSQL_USE_SSL}\&amp;allowPublicKeyRetrieval=true"
      replace_in_file /opt/meeds/conf/server.xml 'username="plf" password="plf"' 'username="'${MEEDS_DB_USER}'" password="'${MEEDS_DB_PASSWORD}'"'
      ;;
    pgsql|postgres|postgresql)
      cat /opt/meeds/conf/server-postgres.xml > /opt/meeds/conf/server.xml
      replace_in_file /opt/meeds/conf/server.xml "jdbc:postgresql://localhost:5432/plf" "jdbc:postgresql://${MEEDS_DB_HOST}:${MEEDS_DB_PORT}/${MEEDS_DB_NAME}"
      replace_in_file /opt/meeds/conf/server.xml 'username="plf" password="plf"' 'username="'${MEEDS_DB_USER}'" password="'${MEEDS_DB_PASSWORD}'"'
      ;;
    *) echo "ERROR: you must provide a supported database type with MEEDS_DB_TYPE environment variable (current value is '${MEEDS_DB_TYPE}')";
      exit 1
      ;;
  esac

  ## Remove file comments
  xmlstarlet ed -L -d "//comment()" /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (xml comments removal)"
    exit 1
  }

  # Update IDM datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@initialSize" -v "${MEEDS_DB_POOL_IDM_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@minIdle" -v "${MEEDS_DB_POOL_IDM_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@maxIdle" -v "${MEEDS_DB_POOL_IDM_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@maxActive" -v "${MEEDS_DB_POOL_IDM_MAX_SIZE}" \
    /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-idm_portal)"
    exit 1
  }

  # Update JCR datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@initialSize" -v "${MEEDS_DB_POOL_JCR_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@minIdle" -v "${MEEDS_DB_POOL_JCR_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@maxIdle" -v "${MEEDS_DB_POOL_JCR_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@maxActive" -v "${MEEDS_DB_POOL_JCR_MAX_SIZE}" \
    /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-jcr_portal)"
    exit 1
  }

  # Update JPA datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-jpa_portal']/@initialSize" -v "${MEEDS_DB_POOL_JPA_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jpa_portal']/@minIdle" -v "${MEEDS_DB_POOL_JPA_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jpa_portal']/@maxIdle" -v "${MEEDS_DB_POOL_JPA_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jpa_portal']/@maxActive" -v "${MEEDS_DB_POOL_JPA_MAX_SIZE}" \
    /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-jpa_portal)"
    exit 1
  }

  ## Remove AJP connector
  xmlstarlet ed -L -d '//Connector[@protocol="AJP/1.3"]' /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (AJP connector removal)"
    exit 1
  }

  ## Add jvmRoute in server.xml, useful for Load balancing in cluster configuration
  if [ -n "${MEEDS_CLUSTER_NODE_NAME}" ]; then
    xmlstarlet ed -L -d "/Server/Service/Engine/@jvmRoute" /opt/meeds/conf/server.xml && \
      xmlstarlet ed -L -s "/Server/Service/Engine" -t attr -n "jvmRoute" -v "${MEEDS_CLUSTER_NODE_NAME}" /opt/meeds/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (jvmRoute definition)"
      exit 1
    }
  fi

  ## Force JSESSIONID to be added in cookie instead of URL
  xmlstarlet ed -L -d "/Context/@cookies" /opt/meeds/conf/context.xml && \
    xmlstarlet ed -L -s "/Context" -t attr -n "cookies" -v "true" /opt/meeds/conf/context.xml || {
    echo "ERROR during xmlstarlet processing (cookies definition)"
    exit 1
  }

  # Proxy configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "proxyName" -v "${MEEDS_PROXY_VHOST}" /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

  if [ "${MEEDS_PROXY_SSL}" = "true" ]; then
    xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "scheme" -v "https" \
      -s "/Server/Service/Connector" -t attr -n "secure" -v "true" \
      -s "/Server/Service/Connector" -t attr -n "proxyPort" -v "${MEEDS_PROXY_PORT}" \
      /opt/meeds/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (configuring Connector proxy ssl)"
      exit 1
    }
    if [ "${MEEDS_PROXY_PORT}" = "443" ]; then
      add_in_meeds_configuration "exo.base.url=https://${MEEDS_PROXY_VHOST}"
    else
      add_in_meeds_configuration "exo.base.url=https://${MEEDS_PROXY_VHOST}:${MEEDS_PROXY_PORT}"
    fi
  else
    xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "scheme" -v "http" \
      -s "/Server/Service/Connector" -t attr -n "secure" -v "false" \
      -s "/Server/Service/Connector" -t attr -n "proxyPort" -v "${MEEDS_PROXY_PORT}" \
      /opt/meeds/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (configuring Connector proxy)"
      exit 1
    }
    if [ "${MEEDS_PROXY_PORT}" = "80" ]; then
      add_in_meeds_configuration "exo.base.url=http://${MEEDS_PROXY_VHOST}"
    else
      add_in_meeds_configuration "exo.base.url=http://${MEEDS_PROXY_VHOST}:${MEEDS_PROXY_PORT}"
    fi
  fi

  # Upload size
  add_in_meeds_configuration "exo.ecms.connector.drives.uploadLimit=${MEEDS_UPLOAD_MAX_FILE_SIZE}"
  add_in_meeds_configuration "exo.social.activity.uploadLimit=${MEEDS_UPLOAD_MAX_FILE_SIZE}"
  add_in_meeds_configuration "wiki.attachment.uploadLimit=${MEEDS_UPLOAD_MAX_FILE_SIZE}"
  add_in_meeds_configuration "exo.uploadLimit=${MEEDS_UPLOAD_MAX_FILE_SIZE}"

  # Tomcat HTTP Thread pool configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "maxThreads" -v "${MEEDS_HTTP_THREAD_MAX}" \
    -s "/Server/Service/Connector" -t attr -n "minSpareThreads" -v "${MEEDS_HTTP_THREAD_MIN}" \
    /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

 # Tomcat valves and listeners configuration
  if [ -e /etc/meeds/host.yml ]; then
    echo "Override default valves and listeners configuration"

    # Remove the default configuration
    xmlstarlet ed -L -d "/Server/Service/Engine/Host/Valve" \
        -d "/Server/Service/Engine/Host/Listener" \
        /opt/meeds/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (Remove default host configuration)"
      exit 1
    }

    i=0
    while [ $i -ge 0 ]; do
      # Declare component
      type=$(yq read /etc/meeds/host.yml components[$i].type)
      if [ "${type}" != "null" ]; then
        className=$(yq read /etc/meeds/host.yml components[$i].className)
        echo "Declare ${type} ${className}"
        xmlstarlet ed -L -s "/Server/Service/Engine/Host" -t elem -n "${type}TMP" -v "" \
            -i "//${type}TMP" -t attr -n "className" -v "${className}" \
            /opt/meeds/conf/server.xml || {
          echo "ERROR during xmlstarlet processing (adding ${className})"
          exit 1
        }

        # Add component attributes
        j=0
        while [ $j -ge 0 ]; do
          attributeName=$(yq read /etc/meeds/host.yml components[$i].attributes[$j].name)
          if [ "${attributeName}" != "null" ]; then
            attributeValue=$(yq read /etc/meeds/host.yml components[$i].attributes[$j].value | tr -d "'")
            xmlstarlet ed -L -i "//${type}TMP" -t attr -n "${attributeName}" -v "${attributeValue}" \
                /opt/meeds/conf/server.xml || {
              echo "ERROR during xmlstarlet processing (adding ${className} / ${attributeName})"
            }

            j=$(($j + 1))
          else
            j=-1
          fi
        done

        # Rename the component to its final type
        xmlstarlet ed -L -r "//${type}TMP" -v "${type}" \
            /opt/meeds/conf/server.xml || {
          echo "ERROR during xmlstarlet processing (renaming ${type}TMP)"
          exit 1
        }

        i=$(($i + 1))
      else
        i=-1
      fi
    done
  fi

  # Mail configuration
  add_in_meeds_configuration "# Mail configuration"
  add_in_meeds_configuration "exo.email.smtp.from=${MEEDS_MAIL_FROM}"
  add_in_meeds_configuration "gatein.email.smtp.from=${MEEDS_MAIL_FROM}"
  add_in_meeds_configuration "exo.email.smtp.host=${MEEDS_MAIL_SMTP_HOST}"
  add_in_meeds_configuration "exo.email.smtp.port=${MEEDS_MAIL_SMTP_PORT}"
  add_in_meeds_configuration "exo.email.smtp.starttls.enable=${MEEDS_MAIL_SMTP_STARTTLS}"
  if [ "${MEEDS_MAIL_SMTP_USERNAME:-}" = "-" ]; then
    add_in_meeds_configuration "exo.email.smtp.auth=false"
    add_in_meeds_configuration "#exo.email.smtp.username="
    add_in_meeds_configuration "#exo.email.smtp.password="
  else
    add_in_meeds_configuration "exo.email.smtp.auth=true"
    add_in_meeds_configuration "exo.email.smtp.username=${MEEDS_MAIL_SMTP_USERNAME}"
    add_in_meeds_configuration "exo.email.smtp.password=${MEEDS_MAIL_SMTP_PASSWORD}"
  fi
  add_in_meeds_configuration "exo.email.smtp.socketFactory.port="
  add_in_meeds_configuration "exo.email.smtp.socketFactory.class="
  # SMTP TLS Version, Example: TLSv1.2
  if [ ! -z "${MEEDS_SMTP_SSL_PROTOCOLS:-}" ]; then 
    add_in_meeds_configuration "mail.smtp.ssl.protocols=${MEEDS_SMTP_SSL_PROTOCOLS}"
  fi

  # JMX configuration
  if [ "${MEEDS_JMX_ENABLED}" = "true" ]; then
    # Create the security files if required
    if [ "${MEEDS_JMX_USERNAME:-}" != "-" ]; then
      if [ "${MEEDS_JMX_PASSWORD:-}" = "-" ]; then
        MEEDS_JMX_PASSWORD="$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=2 count=6 2>/dev/null)"
      fi
    # /opt/meeds/conf/jmxremote.password
    echo "${MEEDS_JMX_USERNAME} ${MEEDS_JMX_PASSWORD}" > /opt/meeds/conf/jmxremote.password
    # /opt/meeds/conf/jmxremote.access
    echo "${MEEDS_JMX_USERNAME} readwrite" > /opt/meeds/conf/jmxremote.access
    fi
  fi

  # Access log configuration
  if [ "${MEEDS_ACCESS_LOG_ENABLED}" = "true" ]; then
    # Add a new valve (just before the end of Host)
    xmlstarlet ed -L -s "/Server/Service/Engine/Host" -t elem -n "ValveTMP" -v "" \
      -i "//ValveTMP" -t attr -n "className" -v "org.apache.catalina.valves.AccessLogValve" \
      -i "//ValveTMP" -t attr -n "pattern" -v "combined" \
      -i "//ValveTMP" -t attr -n "directory" -v "logs" \
      -i "//ValveTMP" -t attr -n "prefix" -v "access" \
      -i "//ValveTMP" -t attr -n "suffix" -v ".log" \
      -i "//ValveTMP" -t attr -n "rotatable" -v "true" \
      -i "//ValveTMP" -t attr -n "renameOnRotate" -v "true" \
      -i "//ValveTMP" -t attr -n "fileDateFormat" -v ".yyyy-MM-dd" \
      -r "//ValveTMP" -v Valve \
      /opt/meeds/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (adding AccessLogValve)"
      exit 1
    }
  fi

  # logback append debug loggers
  if [ ! -z ${MEEDS_LOGBACK_LOGGERS_DEBUG} ]; then 
    # Add new debug loggers (just before the end of configuration)
    loggersList=$(echo ${MEEDS_LOGBACK_LOGGERS_DEBUG} | sed 's/,/ /g')
    for logger in $loggersList; do 
      xmlstarlet ed -L -s "/configuration" -t elem -n "loggerTMP" -v "" \
        -i "//loggerTMP" -t attr -n "name" -v "${logger}" \
        -i "//loggerTMP" -t attr -n "level" -v "DEBUG" \
        -r "//loggerTMP" -v logger \
        /opt/meeds/conf/logback.xml || {
          echo "ERROR during xmlstarlet processing (adding Debug logback loggers)"
          exit 1
        }
    done
  fi

  # Gzip compression
  if [ "${MEEDS_GZIP_ENABLED}" = "true" ]; then
    xmlstarlet ed -L -u "/Server/Service/Connector/@compression" -v "on" /opt/meeds/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (configuring Connector compression)"
      exit 1
    }
  fi
  # Elasticsearch configuration
  add_in_meeds_configuration "# Elasticsearch configuration"
  add_in_meeds_configuration "exo.es.embedded.enabled=false"

  add_in_meeds_configuration "exo.es.search.server.url=${MEEDS_ES_URL}"
  add_in_meeds_configuration "exo.es.index.server.url=${MEEDS_ES_URL}"

  if [ "${MEEDS_ES_USERNAME:-}" != "-" ]; then
    add_in_meeds_configuration "exo.es.index.server.username=${MEEDS_ES_USERNAME}"
    add_in_meeds_configuration "exo.es.index.server.password=${MEEDS_ES_PASSWORD}"
    add_in_meeds_configuration "exo.es.search.server.username=${MEEDS_ES_USERNAME}"
    add_in_meeds_configuration "exo.es.search.server.password=${MEEDS_ES_PASSWORD}"
  else
    add_in_meeds_configuration "#exo.es.index.server.username="
    add_in_meeds_configuration "#exo.es.index.server.password="
    add_in_meeds_configuration "#exo.es.search.server.username="
    add_in_meeds_configuration "#exo.es.search.server.password="
  fi

  add_in_meeds_configuration "exo.es.indexing.replica.number.default=${MEEDS_ES_INDEX_REPLICA_NB}"
  add_in_meeds_configuration "exo.es.indexing.shard.number.default=${MEEDS_ES_INDEX_SHARD_NB}"

  # JOD Converter
  add_in_meeds_configuration "exo.jodconverter.portnumbers=${MEEDS_JODCONVERTER_PORTS}"

  # Meeds Rewards
  add_in_meeds_configuration "# Rewards configuration"
  add_in_meeds_configuration "exo.wallet.admin.key=${MEEDS_REWARDS_WALLET_ADMIN_KEY}"
  add_in_meeds_configuration "exo.wallet.accessPermission=${MEEDS_REWARDS_WALLET_ACCESS_PERMISSION}"
  add_in_meeds_configuration "exo.wallet.blockchain.networkId=${MEEDS_REWARDS_WALLET_NETWORK_ID}"
  add_in_meeds_configuration "exo.wallet.blockchain.network.http=${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP}"
  add_in_meeds_configuration "exo.wallet.blockchain.network.websocket=${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET}"
  add_in_meeds_configuration "exo.wallet.blockchain.token.address=${MEEDS_REWARDS_WALLET_TOKEN_ADDRESS}"
  [ ! -z "${MEEDS_REWARDS_WALLET_ADMIN_PRIVATE_KEY:-}" ] && add_in_meeds_configuration "exo.wallet.admin.privateKey=${MEEDS_REWARDS_WALLET_ADMIN_PRIVATE_KEY}"
  [ ! -z "${MEEDS_REWARDS_WALLET_NETWORK_CRYPTOCURRENCY:-}" ] && add_in_meeds_configuration "exo.wallet.blockchain.network.cryptocurrency=${MEEDS_REWARDS_WALLET_NETWORK_CRYPTOCURRENCY}"
  [ ! -z "${MEEDS_REWARDS_WALLET_TOKEN_SYMBOL:-}" ] && add_in_meeds_configuration "exo.wallet.blockchain.token.symbol=${MEEDS_REWARDS_WALLET_TOKEN_SYMBOL}"
 
 # Rememberme Token expiration
  add_in_meeds_configuration "exo.token.rememberme.expiration.value=${MEEDS_TOKEN_REMEMBERME_EXPIRATION_VALUE}"
  add_in_meeds_configuration "exo.token.rememberme.expiration.unit=${MEEDS_TOKEN_REMEMBERME_EXPIRATION_UNIT}"

  # put a file to avoid doing the configuration twice
  touch /opt/meeds/_done.configuration
fi

# -----------------------------------------------------------------------------
# Install add-ons if needed when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/meeds/_done.addons ]; then
  echo "INFO: add-ons installation already done! skipping this step."
else
  echo "# ------------------------------------ #"
  echo "# Meeds add-ons management start ..."
  echo "# ------------------------------------ #"

  if [ ! -z "${MEEDS_ADDONS_CATALOG_URL:-}" ]; then
    echo "The add-on manager catalog url was overriden with : ${MEEDS_ADDONS_CATALOG_URL}"
    _ADDON_MGR_OPTION_CATALOG="--catalog=${MEEDS_ADDONS_CATALOG_URL}"
  fi

  if [ ! -z "${MEEDS_PATCHES_CATALOG_URL:-}" ]; then
    echo "The add-on manager patches catalog url was defined with : ${MEEDS_PATCHES_CATALOG_URL}"
    _ADDON_MGR_OPTION_PATCHES_CATALOG="--catalog=${MEEDS_PATCHES_CATALOG_URL}"
  fi

  # add-ons removal
  if [ -z "${MEEDS_ADDONS_REMOVE_LIST:-}" ]; then
    echo "# no add-on to uninstall from MEEDS_ADDONS_REMOVE_LIST environment variable."
  else
    echo "# uninstalling default add-ons from MEEDS_ADDONS_REMOVE_LIST environment variable:"
    echo ${MEEDS_ADDONS_REMOVE_LIST} | tr ',' '\n' | while read _addon ; do
      if [ -n "${_addon}" ]; then
        # Uninstall addon
        ${MEEDS_APP_DIR}/addon uninstall ${_addon}
        if [ $? != 0 ]; then
          echo "[ERROR] Problem during add-on [${_addon}] uninstall."
          exit 1
        fi
      fi
    done
    if [ $? != 0 ]; then
      echo "[ERROR] An error during add-on uninstallation phase aborted Meeds startup !"
      exit 1
    fi
  fi

  echo "# ------------------------------------ #"
  
  # add-on installation options
  if [ "${MEEDS_ADDONS_CONFLICT_MODE:-}" = "overwrite" ] || [ "${MEEDS_ADDONS_CONFLICT_MODE:-}" = "ignore" ]; then 
    _ADDON_MGR_OPTIONS="${_ADDON_MGR_OPTIONS:-} --conflict=${MEEDS_ADDONS_CONFLICT_MODE}"
  fi

  if [ "${MEEDS_ADDONS_NOCOMPAT_MODE:-false}" = "true" ]; then 
    _ADDON_MGR_OPTIONS="${_ADDON_MGR_OPTIONS:-} --no-compat"
  fi

  # add-on installation
  if [ -z "${MEEDS_ADDONS_LIST:-}" ]; then
    echo "# no add-on to install from MEEDS_ADDONS_LIST environment variable."
  else
    echo "# installing add-ons from MEEDS_ADDONS_LIST environment variable:"
    echo ${MEEDS_ADDONS_LIST} | tr ',' '\n' | while read _addon ; do
      if [ -n "${_addon}" ]; then
        # Install addon
        ${MEEDS_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} ${_ADDON_MGR_OPTION_CATALOG:-} ${_addon} --force --batch-mode
        if [ $? != 0 ]; then
          echo "[ERROR] Problem during add-on [${_addon}] install."
          exit 1
        fi
      fi
    done
    if [ $? != 0 ]; then
      echo "[ERROR] An error during add-on installation phase aborted Meeds startup !"
      exit 1
    fi
  fi
  echo "# ------------------------------------ #"
  echo "# Meeds add-ons management done."
  echo "# ------------------------------------ #"

  # put a file to avoid doing the configuration twice
  touch /opt/meeds/_done.addons
fi

# -----------------------------------------------------------------------------
# Install patches if needed when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/meeds/_done.patches ]; then
  echo "INFO: patches installation already done! skipping this step."
else
  echo "# ------------------------------------ #"
  echo "# Meeds patches management start ..."
  echo "# ------------------------------------ #"

  # patches installation
  if [ -z "${MEEDS_PATCHES_LIST:-}" ]; then
    echo "# no patches to install from MEEDS_PATCHES_LIST environment variable."
  else
    echo "# installing patches from MEEDS_PATCHES_LIST environment variable:"
    if [ -z "${_ADDON_MGR_OPTION_PATCHES_CATALOG:-}" ]; then
      echo "[ERROR] you must configure a patches catalog url with _ADDON_MGR_OPTION_PATCHES_CATALOG variable for patches installation."
      echo "[ERROR] An error during patches installation phase aborted Meeds startup !"
      exit 1
    fi
    echo ${MEEDS_PATCHES_LIST} | tr ',' '\n' | while read _patche ; do
      if [ -n "${_patche}" ]; then
        # Install patch
        ${MEEDS_APP_DIR}/addon install --conflict=overwrite ${_ADDON_MGR_OPTION_PATCHES_CATALOG:-} ${_patche} --force --batch-mode
        if [ $? != 0 ]; then
          echo "[ERROR] Problem during patch [${_patche}] install."
          exit 1
        fi
      fi
    done
    if [ $? != 0 ]; then
      echo "[ERROR] An error during patches installation phase aborted Meeds startup !"
      exit 1
    fi
  fi
  echo "# ------------------------------------ #"
  echo "# Meeds patches management done."
  echo "# ------------------------------------ #"

  # put a file to avoid doing the configuration twice
  touch /opt/meeds/_done.patches
fi

# -----------------------------------------------------------------------------
# Fix CVE-2021-44228
# -----------------------------------------------------------------------------
CATALINA_OPTS="${CATALINA_OPTS:-} -Dlog4j2.formatMsgNoLookups=true"

# Enable Debug Mode
if [ "${MEEDS_DEBUG_ENABLED:-false}" = "true" ]; then
  CATALINA_OPTS="${CATALINA_OPTS} -agentlib:jdwp=transport=dt_socket,address=*:${MEEDS_DEBUG_PORT:-8000},server=y,suspend=n"
fi

# -----------------------------------------------------------------------------
# LDAP configuration
# -----------------------------------------------------------------------------
CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.jndi.ldap.connect.pool.timeout=${MEEDS_LDAP_POOL_TIMEOUT}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.jndi.ldap.connect.pool.maxsize=${MEEDS_LDAP_POOL_MAX_SIZE}"
if [ ! -z "${MEEDS_LDAP_POOL_DEBUG:-}" ]; then
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.jndi.ldap.connect.pool.debug=${MEEDS_LDAP_POOL_DEBUG}"
fi

# -----------------------------------------------------------------------------
# JMX configuration
# -----------------------------------------------------------------------------
if [ "${MEEDS_JMX_ENABLED}" = "true" ]; then
  CATALINA_OPTS="${CATALINA_OPTS:-} -Dcom.sun.management.jmxremote=true"
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
  CATALINA_OPTS="${CATALINA_OPTS} -Djava.rmi.server.hostname=${MEEDS_JMX_RMI_SERVER_HOSTNAME}"
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.port=${MEEDS_JMX_RMI_REGISTRY_PORT}"
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.rmi.port=${MEEDS_JMX_RMI_SERVER_PORT}"
  if [ "${MEEDS_JMX_USERNAME:-}" = "-" ]; then
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
  else
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.password.file=/opt/meeds/conf/jmxremote.password"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.access.file=/opt/meeds/conf/jmxremote.access"
  fi
fi

# -----------------------------------------------------------------------------
# LOG GC configuration
# -----------------------------------------------------------------------------
if [ "${MEEDS_JVM_LOG_GC_ENABLED}" = "true" ]; then
  MEEDS_JVM_LOG_GC_OPTS="-Xlog:gc=info:file=${MEEDS_LOG_DIR}/platform-gc.log:time"
  echo "Enabling Meeds JVM GC logs with [${MEEDS_JVM_LOG_GC_OPTS}] options ..."
  CATALINA_OPTS="${CATALINA_OPTS} ${MEEDS_JVM_LOG_GC_OPTS}"
  # log rotation to backup previous log file (we don't use GC Log file rotation options because they are not suitable)
  # create the directory for older GC log file
  [ ! -d ${MEEDS_LOG_DIR}/platform-gc/ ] && mkdir ${MEEDS_LOG_DIR}/platform-gc/
  if [ -f ${MEEDS_LOG_DIR}/platform-gc.log ]; then
    MEEDS_JVM_LOG_GC_ARCHIVE="${MEEDS_LOG_DIR}/platform-gc/platform-gc_$(date -u +%F_%H%M%S%z).log"
    mv ${MEEDS_LOG_DIR}/platform-gc.log ${MEEDS_JVM_LOG_GC_ARCHIVE}
    echo "previous Meeds JVM GC log file archived to ${MEEDS_JVM_LOG_GC_ARCHIVE}."
  fi
  echo "Meeds JVM GC logs configured and available at ${MEEDS_LOG_DIR}/platform-gc.log"
fi

# -----------------------------------------------------------------------------
# Create the DATA directories if needed
# -----------------------------------------------------------------------------
if [ ! -d "${MEEDS_DATA_DIR}" ]; then
  mkdir -p "${MEEDS_DATA_DIR}"
fi

if [ ! -d "${MEEDS_FILE_STORAGE_DIR}" ]; then
  mkdir -p "${MEEDS_FILE_STORAGE_DIR}"
fi

# Change the device for antropy generation
CATALINA_OPTS="${CATALINA_OPTS:-} -Djava.security.egd=file:/dev/./urandom"

# Wait for database availability
case "${MEEDS_DB_TYPE}" in
  mysql)
    echo "Waiting for database ${MEEDS_DB_TYPE} availability at ${MEEDS_DB_HOST}:${MEEDS_DB_PORT} ..."
    wait-for ${MEEDS_DB_HOST}:${MEEDS_DB_PORT} -s -t ${MEEDS_DB_TIMEOUT}
    if [ $? != 0 ]; then
      echo "[ERROR] The ${MEEDS_DB_TYPE} database ${MEEDS_DB_HOST}:${MEEDS_DB_PORT} was not available within ${MEEDS_DB_TIMEOUT}s ! eXo startup aborted ..."
      exit 1
    else
      echo "Database ${MEEDS_DB_TYPE} is available, continue starting..."
    fi
    ;;
  pgsql|postgres|postgresql)
    echo "Waiting for database ${MEEDS_DB_TYPE} availability at ${MEEDS_DB_HOST}:${MEEDS_DB_PORT} ..."
    wait-for ${MEEDS_DB_HOST}:${MEEDS_DB_PORT} -s -t ${MEEDS_DB_TIMEOUT}
    if [ $? != 0 ]; then
      echo "[ERROR] The ${MEEDS_DB_TYPE} database ${MEEDS_DB_HOST}:${MEEDS_DB_PORT} was not available within ${MEEDS_DB_TIMEOUT}s ! eXo startup aborted ..."
      exit 1
    else
      echo "Database ${MEEDS_DB_TYPE} is available, continue starting..."
    fi
    ;;
esac

# Wait for elasticsearch availability
echo "Waiting for external elastic search availability at ${MEEDS_ES_HOST}:${MEEDS_ES_PORT} ..."
wait-for ${MEEDS_ES_HOST}:${MEEDS_ES_PORT} -s -t ${MEEDS_ES_TIMEOUT}
if [ $? != 0 ]; then
  echo "[ERROR] The external elastic search ${MEEDS_ES_HOST}:${MEEDS_ES_PORT} was not available within ${MEEDS_ES_TIMEOUT}s ! Meeds startup aborted ..."
  exit 1
fi

set +u		# DEACTIVATE unbound variable check
