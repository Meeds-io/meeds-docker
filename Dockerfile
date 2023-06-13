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
# Dockerizing base image for Meeds with:
#
# - Libre Office
# - Meeds

# Build:    docker build -t meeds-io/meeds .
#
# Run:      docker run -p 8080:8080 meeds-io/meeds
#           docker run -d -p 8080:8080 meeds-io/meeds
#           docker run -d --rm -p 8080:8080 -v meeds_data:/srv/meeds meeds-io/meeds
#           docker run -d -p 8080:8080 -v $(pwd)/setenv-customize.sh:/opt/meeds/bin/setenv-customize.sh:ro meeds-io/meeds

FROM    exoplatform/jdk:openjdk-17-ubuntu-2204
LABEL   maintainer="Meeds <docker@exoplatform.com>"

# Install the needed packages
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get -y update  && \
    apt-get -y install apt-utils    --no-install-recommends && \
    apt-get -y install libfreetype6 --no-install-recommends && \
    apt-get -y install fontconfig   --no-install-recommends && \
    apt-get -y install fonts-dejavu --no-install-recommends && \
    apt-get -y upgrade ${_APT_OPTIONS} && \
    apt-get -y install ${_APT_OPTIONS} xmlstarlet && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

# Build Arguments and environment variables
ARG MEEDS_VERSION=1.4.2-exo-RC02

# this allow to specify a Meeds download url
ARG DOWNLOAD_URL
# this allow to specifiy a user to download a protected binary
ARG DOWNLOAD_USER
# allow to override the list of addons to package by default
ARG ADDONS="meeds-jdbc-driver-mysql:2.0.4 meeds-jdbc-driver-postgresql:2.3.0"
# Default base directory on the plf archive
ARG ARCHIVE_BASE_DIR=meeds-community-${MEEDS_VERSION}
ARG ARCHIVE_DOWNLOAD_PATH=/srv/downloads/meeds-${MEEDS_VERSION}.zip

ENV MEEDS_APP_DIR   /opt/meeds
ENV MEEDS_CONF_DIR  /etc/meeds
ENV MEEDS_DATA_DIR  /srv/meeds
ENV MEEDS_LOG_DIR   /var/log/meeds
ENV MEEDS_TMP_DIR   /tmp/meeds-tmp

ENV MEEDS_USER meeds
ENV MEEDS_GROUP ${MEEDS_USER}

# Customise system

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# giving all rights to 'meeds' user
# (we use 999 as uid like in official Docker images)
RUN useradd --create-home -u 999 --user-group --shell /bin/bash ${MEEDS_USER}

# Create needed directories
RUN mkdir -p ${MEEDS_DATA_DIR}   && chown ${MEEDS_USER}:${MEEDS_GROUP} ${MEEDS_DATA_DIR} \
    && mkdir -p ${MEEDS_TMP_DIR} && chown ${MEEDS_USER}:${MEEDS_GROUP} ${MEEDS_TMP_DIR} \
    && mkdir -p ${MEEDS_LOG_DIR} && chown ${MEEDS_USER}:${MEEDS_GROUP} ${MEEDS_LOG_DIR}

RUN if [ -n "${DOWNLOAD_USER}" ]; then PARAMS="-u ${DOWNLOAD_USER}"; fi && \
  echo "Building an image with Meeds version : ${MEEDS_VERSION}" && \
  if [ ! -n "${DOWNLOAD_URL}" ]; then \
  DOWNLOAD_URL="https://repository.exoplatform.org/service/local/artifact/maven/redirect?r=public&g=io.meeds.distribution&a=plf-community-tomcat-standalone&v=${MEEDS_VERSION}&p=zip"; \
  fi && \
  echo "Downloading Meeds server distribution version : ${MEEDS_VERSION} ..." && \
  if [ ! -f "${ARCHIVE_DOWNLOAD_PATH}" ]; then curl ${PARAMS} -S -L -o ${ARCHIVE_DOWNLOAD_PATH} ${DOWNLOAD_URL}; fi && \
  rm -rf /srv/downloads/${ARCHIVE_BASE_DIR} && \
  echo "Unpacking Downloaded Meeds server" && \
  unzip -q ${ARCHIVE_DOWNLOAD_PATH} -d /srv/downloads/ && \
  rm -rf ${MEEDS_APP_DIR} && \
  mv /srv/downloads/${ARCHIVE_BASE_DIR} ${MEEDS_APP_DIR} && \
  chown -R ${MEEDS_USER}:${MEEDS_GROUP} ${MEEDS_APP_DIR} && \
  ln -s ${MEEDS_APP_DIR}/gatein/conf /etc/meeds && \
  rm -rf ${MEEDS_APP_DIR}/logs && ln -s ${MEEDS_LOG_DIR} ${MEEDS_APP_DIR}/logs && \
  rm -f ${ARCHIVE_DOWNLOAD_PATH}

# Install Docker customization file
ADD scripts/setenv-docker-customize.sh ${MEEDS_APP_DIR}/bin/setenv-docker-customize.sh
RUN chmod 755 ${MEEDS_APP_DIR}/bin/setenv-docker-customize.sh && \
  chown ${MEEDS_USER}:${MEEDS_GROUP} ${MEEDS_APP_DIR}/bin/setenv-docker-customize.sh && \
  sed -i '/# Load custom settings/i \
  \# Load custom settings for docker environment\n\
  [ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
  && . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
  || echo "No Docker Meeds customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
  ' ${MEEDS_APP_DIR}/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${MEEDS_APP_DIR}/bin/setenv.sh

USER ${MEEDS_USER}
EXPOSE 8080
VOLUME ["/srv/meeds"]

# INSTALLING Meeds addons
RUN for a in ${ADDONS}; do echo "Installing addon $a"; /opt/meeds/addon install $a; done

WORKDIR ${MEEDS_LOG_DIR}
ENTRYPOINT ["/usr/local/bin/tini", "--"]
# Health Check
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1
CMD [ "/opt/meeds/start_eXo.sh" ]
