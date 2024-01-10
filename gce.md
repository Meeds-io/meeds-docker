# How to run ?

## Getting started

Weclome to Meeds-io Startup tutorial. Here we will show you how to run Meeds in few steps. To get started, click on Start!

## VM Setup
Elasticsearch uses a mmapfs directory by default to store its indices. The default operating system limits on mmap counts is likely to be too low, which may result in out of memory exceptions. See [doc](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html).
```
sudo sysctl -w vm.max_map_count=262144
```
## Start Meeds
```
docker-compose up -d
docker-compose logs -f meeds
```
## Preview Port 8080
After Meeds startup. Click on `Web preview` Button and click on `Preview on Port 8080`. Enjoy!

## Stop Meeds
 - To stop Meeds without removing docker containers:
    ```
    docker-compose stop
    ```
 - To stop Meeds with removing docker containers:
    ```
    docker-compose down
    ```
 - To stop Meeds with removing docker containers and volumes:
    ```
    docker-compose down -v
    ```
You can start again meeds by following the previous step.

That's all :)