# How to run?

## Getting started

Welcome to the Meeds-io Startup tutorial. Here we will show you how to run Meeds in a few steps. To get started, click on Start!

## VM Setup
Elasticsearch uses a mmapfs directory by default to store its indices. The default operating system limits on mmap counts are likely to be too low, which may result in out-of-memory exceptions. See [doc](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html).
```bash
sudo sysctl -w vm.max_map_count=262144
```
## Start Meeds
```bash
docker-compose -p demo up -d
docker-compose -p demo logs -f meeds
```

Wait for Meeds's startup. A log message should appear:
```
| INFO  | Server startup in [XXXXX] milliseconds [org.apache.catalina.startup.Catalina<main>]
```
After Meeds startup. Click on `Web preview` <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Button and click on `Preview on Port 8080`. Enjoy!

## Stop Meeds
Hope you enjoyed Meeds. You can tear down the server by following one of these options:
 - To stop Meeds without removing docker containers:
    ```bash
    docker-compose -p demo stop
    ```
 - To stop Meeds by removing docker containers:
    ```bash
    docker-compose -p demo down
    ```
 - To stop Meeds by removing docker containers and volumes:
    ```bash
    docker-compose -p demo down -v
    ```
You can start again meeds by following the previous step.

You can check out our Github [organization](https://github.com/Meeds-io) and our [builders hub](https://builders.meeds.io).

That's all :)