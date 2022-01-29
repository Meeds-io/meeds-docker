# Meeds Docker image <!-- omit in toc -->

Meeds Docker image support `HSQLDB` (for testing).

## Quick start

The prerequisites are :

- Docker daemon version 12+ + internet access
- 4GB of available RAM + 1GB of disk

The most basic way to start Meeds Server for *evaluation* purpose is to execute

```bash
docker run -v meeds_data:/srv/meeds -p 8080:8080 meedsio/meeds
```

and then waiting the log line which say that the server is started.

When ready just go to <http://localhost:8080> and follow the instructions.

## Configuration options

### Add-ons

Some add-ons are already installed in the Meeds image but you can install other one or remove some of the pre-installed one :

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                               |
|------------------------|-----------|---------------|-------------------------------------------------------------------------------------------|
| MEEDS_ADDONS_LIST        | NO        | -             | commas separated list of add-ons to install (ex: meeds-wallet,meeds-perk-store:2.0.x-SNAPSHOT)    |
| MEEDS_ADDONS_REMOVE_LIST | NO        | -             | commas separated list of add-ons to uninstall |
| MEEDS_ADDONS_CATALOG_URL | NO        | -             | The url of a valid Meeds addons Catalog                                                            |

### JVM

The standard Meeds Server environment variables can be used :

| VARIABLE                   | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                      |
|----------------------------|-----------|---------------|--------------------------------------------------------------------------------------------------|
| MEEDS_JVM_SIZE_MIN           | NO        | `512m`        | specify the jvm minimum allocated memory size (-Xms parameter)                                   |
| MEEDS_JVM_SIZE_MAX           | NO        | `3g`          | specify the jvm maximum allocated memory size (-Xmx parameter)                                   |
| MEEDS_JVM_PERMSIZE_MAX       | NO        | `256m`        | (Java 7) specify the jvm maximum allocated memory to Permgen (-XX:MaxPermSize parameter)         |
| MEEDS_JVM_METASPACE_SIZE_MAX | NO        | `512m`        | (Java 8+) specify the jvm maximum allocated memory to MetaSpace (-XX:MaxMetaspaceSize parameter) |
| MEEDS_JVM_USER_LANGUAGE      | NO        | `en`          | specify the jvm locale for langage (-Duser.language parameter)                                   |
| MEEDS_JVM_USER_REGION        | NO        | `US`          | specify the jvm local for region (-Duser.region parameter)                                       |
| MEEDS_JVM_LOG_GC_ENABLED     | NO        | `false`       | activate the JVM GC log file generation (location: $MEEDS_LOG_DIR/platform-gc.log) (5.1.0-RC12+)   |

### Frontend proxy

The following environment variables must be passed to the container to configure Tomcat proxy settings:

| VARIABLE        | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                                |
|-----------------|-----------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| MEEDS_PROXY_VHOST | NO        | `localhost`   | specify the virtual host name to reach Meeds Server                                                                                        |
| MEEDS_PROXY_PORT  | NO        | -             | which port to use on the proxy server ? if empty it will automatically defined regarding MEEDS_PROXY_SSL value (true => 443 / false => 8080) |
| MEEDS_PROXY_SSL   | NO        | `false`       | is ssl activated on the proxy server ? (true / false)                                                                                      |

### Tomcat

The following environment variables can be passed to the container to configure Tomcat settings

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                  |
|------------------------|-----------|---------------|------------------------------------------------------------------------------|
| MEEDS_HTTP_THREAD_MAX    | NO        | `200`         | maximum number of threads in the tomcat http connector                       |
| MEEDS_HTTP_THREAD_MIN    | NO        | `10`          | minimum number of threads ready in the tomcat http connector                 |
| MEEDS_ACCESS_LOG_ENABLED | NO        | `false`       | activate Tomcat access log with combine format and a daily log file rotation |
| MEEDS_GZIP_ENABLED       | NO        | `true`        | activate Tomcat Gzip compression for assets mimetypes


#### Data on disk

The following environment variables must be passed to the container in order to work :

| VARIABLE                   | MANDATORY | DEFAULT VALUE                | DESCRIPTION                                                                                  |
|----------------------------|-----------|------------------------------|----------------------------------------------------------------------------------------------|
| MEEDS_DATA_DIR               | NO        | `/srv/meeds`                   | the directory to store Meeds Server data                                                     |
| MEEDS_FILE_STORAGE_DIR       | NO        | `${MEEDS_DATA_DIR}/files`      | the directory to store Meeds Server data                                                     |
| MEEDS_FILE_STORAGE_RETENTION | NO        | `30`                         | the number of days to keep deleted files on disk before definitively remove it from the disk |
| MEEDS_UPLOAD_MAX_FILE_SIZE   | NO        | `200`                        | maximum authorized size for file upload in MB.                                               |
| MEEDS_FILE_UMASK             | NO        | `0022`                       | the umask used for files generated by Meeds                                                    |

### Database

The following environment variables must be passed to the container in order to work :

| VARIABLE                  | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                           |
|---------------------------|-----------|---------------|---------------------------------------------------------------------------------------|
| MEEDS_DB_TYPE               | NO        | `hsqldb`      | Meeds server uses hsqldb by default                                       |
| MEEDS_DB_POOL_IDM_INIT_SIZE | NO        | `5`           | the init size of IDM datasource pool                                                  |
| MEEDS_DB_POOL_IDM_MAX_SIZE  | NO        | `20`          | the max size of IDM datasource pool                                                   |
| MEEDS_DB_POOL_JCR_INIT_SIZE | NO        | `5`           | the init size of JCR datasource pool                                                  |
| MEEDS_DB_POOL_JCR_MAX_SIZE  | NO        | `20`          | the max size of JCR datasource pool                                                   |
| MEEDS_DB_POOL_JPA_INIT_SIZE | NO        | `5`           | the init size of JPA datasource pool                                                  |
| MEEDS_DB_POOL_JPA_MAX_SIZE  | NO        | `20`          | the max size of JPA datasource pool                                                   |
| MEEDS_DB_TIMEOUT            | NO        | `60`          | the number of seconds to wait for database availability before cancelling Meeds startup |

### ElasticSearch

The following environment variables should be passed to the container in order to configure the search feature on an external Elastic Search server:

| VARIABLE                | MANDATORY | DEFAULT VALUE  | DESCRIPTION                                                                                                                                                                                                                                                                    |
|-------------------------|-----------|----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MEEDS_ES_SCHEME           | NO        | `http`         | the elasticsearch server scheme to use from the Meeds Server jvm perspective (http / https).                                                                                                                                                                            |
| MEEDS_ES_HOST             | NO        | `localhost`    | the elasticsearch server hostname to use from the Meeds Server jvm perspective.                                                                                                                                                                                         |
| MEEDS_ES_PORT             | NO        | `9200`         | the elasticsearch server port to use from the Meeds Server jvm perspective.                                                                                                                                                                                             |
| MEEDS_ES_USERNAME         | NO        | -              | the username to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).                                                                                                                                                            |
| MEEDS_ES_PASSWORD         | NO        | -              | the password to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).                                                                                                                                                            |
| MEEDS_ES_INDEX_REPLICA_NB | NO        | `0`            | the number of replicat for elasticsearch indexes (leave 0 if you don't have an elasticsearch cluster).                                                                                                                                                                         |
| MEEDS_ES_INDEX_SHARD_NB   | NO        | `0`            | the number of shard for elasticsearch indexes.                                                                                                                                                                                                                                 |
| MEEDS_ES_TIMEOUT          | NO        | `60`           | the number of seconds to wait for elasticsearch availability before cancelling Meeds startup                                                                                                                                               |

### Mail

The following environment variables should be passed to the container in order to configure the mail server configuration to use :

| VARIABLE               | MANDATORY | DEFAULT VALUE             | DESCRIPTION                                         |
|------------------------|-----------|---------------------------|-----------------------------------------------------|
| MEEDS_MAIL_FROM          | NO        | `noreply@example.com` | "from" field of emails sent by Meeds Server             |
| MEEDS_MAIL_SMTP_HOST     | NO        | `localhost`               | SMTP Server hostname                                |
| MEEDS_MAIL_SMTP_PORT     | NO        | `25`                      | SMTP Server port                                    |
| MEEDS_MAIL_SMTP_STARTTLS | NO        | `false`                   | true to enable the secure (TLS) SMTP. See RFC 3207. |
| MEEDS_MAIL_SMTP_USERNAME | NO        | -                         | authentication username for smtp server (if needed) |
| MEEDS_MAIL_SMTP_PASSWORD | NO        | -                         | authentication password for smtp server (if needed) |

### JMX

The following environment variables should be passed to the container in order to configure JMX :

| VARIABLE                    | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                               |
|-----------------------------|-----------|---------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| MEEDS_JMX_ENABLED             | NO        | `true`        | activate JMX listener                                                                                                                     |
| MEEDS_JMX_RMI_REGISTRY_PORT   | NO        | `10001`       | JMX RMI Registry port                                                                                                                     |
| MEEDS_JMX_RMI_SERVER_PORT     | NO        | `10002`       | JMX RMI Server port                                                                                                                       |
| MEEDS_JMX_RMI_SERVER_HOSTNAME | NO        | `localhost`   | JMX RMI Server hostname                                                                                                                   |
| MEEDS_JMX_USERNAME            | NO        | -             | a username for JMX connection (if no username is provided, the JMX access is unprotected)                                                 |
| MEEDS_JMX_PASSWORD            | NO        | -             | a password for JMX connection (if no password is specified a random one will be generated and stored in /opt/meeds/conf/jmxremote.password) |

With the default parameters you can connect to JMX with `service:jmx:rmi://localhost:10002/jndi/rmi://localhost:10001/jmxrmi` without authentication.

### Reward Wallet

The following environment variables should be passed to the container in order to configure Meeds Rewards wallet:

| VARIABLE                                      | MANDATORY | DEFAULT VALUE                                                    | DESCRIPTION                                                                                                                                                                                                                       |
|-----------------------------------------------|-----------|------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MEEDS_REWARDS_WALLET_ADMIN_KEY                  | YES       | `changeThisKey`                                                  | password used to encrypt the Admin wallet’s private key stored in database. If its value is modified after server startup, the private key of admin wallet won’t be decrypted anymore, preventing all administrative operations |
| MEEDS_REWARDS_WALLET_ACCESS_PERMISSION          | NO        | `/platform/users`                                                | to restrict access to wallet application to a group of users (ex: member:/spaces/internal_space)                                                                                                                                  |
| MEEDS_REWARDS_WALLET_NETWORK_ID                 | NO        | `1` (mainnet)                                                    | ID of the Ethereum network to use (see: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md#list-of-chain-ids>)                                                                                                         |
| MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP      | NO        | `https://mainnet.infura.io/v3/a1ac85aea9ce4be88e9e87dad7c01d40`  | https url to access to the Ethereum API for the chosen network id                                                                                                                                                                 |
| MEEDS_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET | NO        | `wss://mainnet.infura.io/ws/v3/a1ac85aea9ce4be88e9e87dad7c01d40` | wss url to access to the Ethereum API for the chosen network id                                                                                                                                                                   |
| MEEDS_REWARDS_WALLET_TOKEN_ADDRESS              | NO        | `0xc76987d43b77c45d51653b6eb110b9174acce8fb`                     | address of the contract for the official rewarding token promoted by Meeds                                                                                                                                                          |                                                                                                  |

## How-to

### configure Meeds Server behind a reverse-proxy

You have to specify the following environment variables to configure Meeds Server (see upper section for more parameters and details) :

```bash
docker run -d \
  -p 8080:8080 \
  -e MEEDS_PROXY_VHOST="my.public-facing-hostname.org" \
  meedsio/meeds
```

You can also use Docker Compose (see the provided `docker-compose.yml` file as an example).

### see Meeds Server logs

```bash
docker logs --follow <CONTAINER_NAME>
```

### install Meeds Server add-ons

To install add-ons in the container, provide a commas separated list of add-ons you want to install in a `MEEDS_ADDONS_LIST` environment variable to the container:

```bash
docker run -d \
  -p 8080:8080 \
  -e MEEDS_ADDONS_LIST="meeds-wallet:2.0.x-SNAPSHOT" \
  meedsio/meeds
```

INFO: the provided add-ons list will be installed in the container during the container creation.

### list Meeds Server add-ons available

In a *running container* execute the following command:

```bash
docker exec <CONTAINER_NAME> /opt/meeds/addon list
```

### list Meeds Server add-ons installed

In a *running container* execute the following command:

```bash
docker exec <CONTAINER_NAME> /opt/meeds/addon list --installed
```

### customize some Meeds Server settings

All previously mentioned [environment variables](#configuration-options) can be defined in a standard Docker way with `-e ENV_VARIABLE="value"` parameters :

```bash
docker run -d \
  -p 8080:8080 \
  -e MEEDS_JVM_SIZE_MAX="8g" \
  meedsio/meeds
```

Some [eXo configuration properties](https://docs.exoplatform.org/PLF50/PLFAdminGuide.Configuration.Properties_reference.html) can also be defined in an `exo.properties` file. In this case, just create this file and bind mount it in the Docker container :

```bash
docker run -d \
  -p 8080:8080 \
  -v /absolute/path/to/exo.properties:/etc/meeds/exo.properties:ro \
  meedsio/meeds
```

## Image build

The simplest way to build this image is to use default values :

```bash
    docker build -t meedsio/meeds .
```

This will produce an image with the current Meeds Server.
