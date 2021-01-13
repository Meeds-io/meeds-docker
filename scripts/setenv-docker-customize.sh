#!/bin/bash -eu
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
  *)
    echo "ERROR: you must provide a supported database type with MEEDS_DB_TYPE environment variable (current value is '${MEEDS_DB_TYPE}')"
    echo "ERROR: supported database types are :"
    echo "ERROR: HSQLDB     (MEEDS_DB_TYPE = hsqldb) (default)"
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

[ -z "${MEEDS_ES_EMBEDDED}" ] && MEEDS_ES_EMBEDDED="true"
[ -z "${MEEDS_ES_TIMEOUT}" ] && MEEDS_ES_TIMEOUT="60"
[ -z "${MEEDS_ES_EMBEDDED_DATA}" ] && MEEDS_ES_EMBEDDED_DATA="/srv/meeds/es"
[ -z "${MEEDS_ES_SCHEME}" ] && MEEDS_ES_SCHEME="http"
[ -z "${MEEDS_ES_HOST}" ] && MEEDS_ES_HOST="localhost"
[ -z "${MEEDS_ES_PORT}" ] && MEEDS_ES_PORT="9200"
MEEDS_ES_URL="${MEEDS_ES_SCHEME}://${MEEDS_ES_HOST}:${MEEDS_ES_PORT}"
[ -z "${MEEDS_ES_USERNAME}" ] && MEEDS_ES_USERNAME="-"
[ -z "${MEEDS_ES_PASSWORD}" ] && MEEDS_ES_PASSWORD="-"
[ -z "${MEEDS_ES_INDEX_REPLICA_NB}" ] && MEEDS_ES_INDEX_REPLICA_NB="1"
[ -z "${MEEDS_ES_INDEX_SHARD_NB}" ] && MEEDS_ES_INDEX_SHARD_NB="5"

[ -z "${MEEDS_JODCONVERTER_PORTS}" ] && MEEDS_JODCONVERTER_PORTS="2002"

[ -z "${MEEDS_REWARDS_WALLET_ADMIN_KEY}" ] && MEEDS_REWARDS_WALLET_ADMIN_KEY="changeThisKey"
[ -z "${MEEDS_REWARDS_WALLET_ACCESS_PERMISSION}" ] && MEEDS_REWARDS_WALLET_ACCESS_PERMISSION="/platform/user"
[ -z "${MEEDS_REWARDS_WALLET_NETWORK_ID}" ] && MEEDS_REWARDS_WALLET_NETWORK_ID="1"
[ -z "${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP}" ] && MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP="https://mainnet.infura.io/v3/a1ac85aea9ce4be88e9e87dad7c01d40"
[ -z "${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET}" ] && MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET="wss://mainnet.infura.io/ws/v3/a1ac85aea9ce4be88e9e87dad7c01d40"
[ -z "${MEEDS_REWARDS_WALLET_TOKEN_ADDRESS}" ] && MEEDS_REWARDS_WALLET_TOKEN_ADDRESS="0xc76987d43b77c45d51653b6eb110b9174acce8fb"

set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/meeds/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else

  if [ ! -z "${MEEDS_ADDONS_CATALOG_URL:-}" ]; then
    echo "The add-on manager catalog url was overriden with : ${MEEDS_ADDONS_CATALOG_URL}"
    _ADDON_MGR_OPTION_CATALOG="--catalog=${MEEDS_ADDONS_CATALOG_URL}"
  fi

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
    *) echo "ERROR: you must provide a supported database type with MEEDS_DB_TYPE environment variable (current value is '${MEEDS_DB_TYPE}')";
      exit 1;;
  esac

  ## Remove file comments
  xmlstarlet ed -L -d "//comment()" /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (xml comments removal)"
    exit 1
  }

    # Update IDM datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@initialSize" -v "${MEEDS_DB_POOL_IDM_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@maxActive" -v "${MEEDS_DB_POOL_IDM_MAX_SIZE}" \
    /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-idm_portal)"
    exit 1
  }

  # Update JCR datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@initialSize" -v "${MEEDS_DB_POOL_JCR_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@maxActive" -v "${MEEDS_DB_POOL_JCR_MAX_SIZE}" \
    /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-jcr_portal)"
    exit 1
  }

  # Update JPA datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-jpa_portal']/@initialSize" -v "${MEEDS_DB_POOL_JPA_INIT_SIZE}" \
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

  # Proxy configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "proxyName" -v "${MEEDS_PROXY_VHOST}" /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

  if [ "${MEEDS_PROXY_SSL}" = "true" ]; then
    xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "scheme" -v "https" \
      -s "/Server/Service/Connector" -t attr -n "secure" -v "false" \
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

  # Tomcat HTTP Thread pool configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "maxThreads" -v "${MEEDS_HTTP_THREAD_MAX}" \
    -s "/Server/Service/Connector" -t attr -n "minSpareThreads" -v "${MEEDS_HTTP_THREAD_MIN}" \
    /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

  # Add a new valve to replace the proxy ip by the client ip (just before the end of Host)
  xmlstarlet ed -L -s "/Server/Service/Engine/Host" -t elem -n "ValveTMP" -v "" \
  -i "//ValveTMP" -t attr -n "className" -v "org.apache.catalina.valves.RemoteIpValve" \
  -i "//ValveTMP" -t attr -n "remoteIpHeader" -v "x-forwarded-for" \
  -i "//ValveTMP" -t attr -n "proxiesHeader" -v "x-forwarded-by" \
  -i "//ValveTMP" -t attr -n "protocolHeader" -v "x-forwarded-proto" \
  -r "//ValveTMP" -v Valve \
  /opt/meeds/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding RemoteIpValve)"
    exit 1
  }

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

  # JMX configuration
  if [ "${MEEDS_JMX_ENABLED}" = "true" ]; then
    # insert the listener before the "Global JNDI resources" line
    xmlstarlet ed -L -i "/Server/GlobalNamingResources" -t elem -n ListenerTMP -v "" \
      -i "//ListenerTMP" -t attr -n "className" -v "org.apache.catalina.mbeans.JmxRemoteLifecycleListener" \
      -i "//ListenerTMP" -t attr -n "rmiRegistryPortPlatform" -v "${MEEDS_JMX_RMI_REGISTRY_PORT}" \
      -i "//ListenerTMP" -t attr -n "rmiServerPortPlatform" -v "${MEEDS_JMX_RMI_SERVER_PORT}" \
      -i "//ListenerTMP" -t attr -n "useLocalPorts" -v "false" \
      -r "//ListenerTMP" -v "Listener" \
      /opt/meeds/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (adding JmxRemoteLifecycleListener)"
      exit 1
    }
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

  # Elasticsearch configuration
  add_in_meeds_configuration "# Elasticsearch configuration"
  add_in_meeds_configuration "exo.es.embedded.enabled=${MEEDS_ES_EMBEDDED}"
  if [ "${MEEDS_ES_EMBEDDED}" = "true" ]; then
    add_in_meeds_configuration "es.network.host=0.0.0.0" # we listen on all IPs inside the container
    add_in_meeds_configuration "es.discovery.zen.ping.multicast.enabled=false"
    add_in_meeds_configuration "es.http.port=${MEEDS_ES_PORT}"
    add_in_meeds_configuration "es.path.data=${MEEDS_ES_EMBEDDED_DATA}"
  else
    # Remove eXo ES Embedded add-on
    MEEDS_ADDONS_REMOVE_LIST="${MEEDS_ADDONS_REMOVE_LIST:-},meeds-es-embedded"
  fi

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

  # eXo Rewards
  add_in_meeds_configuration "# Rewards configuration"
  add_in_meeds_configuration "exo.wallet.admin.key=${MEEDS_REWARDS_WALLET_ADMIN_KEY}"
  add_in_meeds_configuration "exo.wallet.accessPermission=${MEEDS_REWARDS_WALLET_ACCESS_PERMISSION}"
  add_in_meeds_configuration "exo.wallet.blockchain.networkId=${MEEDS_REWARDS_WALLET_NETWORK_ID}"
  add_in_meeds_configuration "exo.wallet.blockchain.network.http=${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP}"
  add_in_meeds_configuration "exo.wallet.blockchain.network.websocket=${MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET}"
  add_in_meeds_configuration "exo.wallet.blockchain.token.address=${MEEDS_REWARDS_WALLET_TOKEN_ADDRESS}"

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
  echo "# eXo add-ons management start ..."
  echo "# ------------------------------------ #"

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
      echo "[ERROR] An error during add-on uninstallation phase aborted eXo startup !"
      exit 1
    fi
  fi

  echo "# ------------------------------------ #"
  
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
      echo "[ERROR] An error during add-on installation phase aborted eXo startup !"
      exit 1
    fi
  fi
  echo "# ------------------------------------ #"
  echo "# eXo add-ons management done."
  echo "# ------------------------------------ #"

  # put a file to avoid doing the configuration twice
  touch /opt/meeds/_done.addons
fi

# -----------------------------------------------------------------------------
# JMX configuration
# -----------------------------------------------------------------------------
if [ "${MEEDS_JMX_ENABLED}" = "true" ]; then
  CATALINA_OPTS="${CATALINA_OPTS:-} -Dcom.sun.management.jmxremote=true"
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
  CATALINA_OPTS="${CATALINA_OPTS} -Djava.rmi.server.hostname=${MEEDS_JMX_RMI_SERVER_HOSTNAME}"
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
  echo "Enabling eXo JVM GC logs with [${MEEDS_JVM_LOG_GC_OPTS}] options ..."
  CATALINA_OPTS="${CATALINA_OPTS} ${MEEDS_JVM_LOG_GC_OPTS}"
  # log rotation to backup previous log file (we don't use GC Log file rotation options because they are not suitable)
  # create the directory for older GC log file
  [ ! -d ${MEEDS_LOG_DIR}/platform-gc/ ] && mkdir ${MEEDS_LOG_DIR}/platform-gc/
  if [ -f ${MEEDS_LOG_DIR}/platform-gc.log ]; then
    MEEDS_JVM_LOG_GC_ARCHIVE="${MEEDS_LOG_DIR}/platform-gc/platform-gc_$(date -u +%F_%H%M%S%z).log"
    mv ${MEEDS_LOG_DIR}/platform-gc.log ${MEEDS_JVM_LOG_GC_ARCHIVE}
    echo "previous eXo JVM GC log file archived to ${MEEDS_JVM_LOG_GC_ARCHIVE}."
  fi
  echo "eXo JVM GC logs configured and available at ${MEEDS_LOG_DIR}/platform-gc.log"
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

# Wait for elasticsearch availability (if external)
if [ "${MEEDS_ES_EMBEDDED}" != "true" ]; then
  echo "Waiting for external elastic search availability at ${MEEDS_ES_HOST}:${MEEDS_ES_PORT} ..."
  wait-for ${MEEDS_ES_HOST}:${MEEDS_ES_PORT} -s -t ${MEEDS_ES_TIMEOUT}
  if [ $? != 0 ]; then
    echo "[ERROR] The external elastic search ${MEEDS_ES_HOST}:${MEEDS_ES_PORT} was not available within ${MEEDS_ES_TIMEOUT}s ! Meeds startup aborted ..."
    exit 1
  fi
fi

set +u		# DEACTIVATE unbound variable check
