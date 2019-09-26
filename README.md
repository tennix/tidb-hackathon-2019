# TiDB 2019 Hackathon dev

## Prepare development environment

``` shell
docker build -t hackathon-dev -f Dockerfile_dev .
git clone https://github.com/pingcap/pd
git clone https://github.com/pingcap/tidb
git clone https://github.com/tikv/tikv
```

## Build pd/tikv/tidb from source

1. Build the binaries

``` shell
docker run -it --name hackathon-dev -v $PWD/tikv:/tikv -v $PWD/tidb:/tidb -v $PWD/pd:/pd hackathon-dev bash

cd /pd && make
cd /tidb && make
cd /tikv && make dev
```

2. Build the docker image

``` shell
docker build -t hackathon .
```

## What we want to achieve

* No PD component, deployment is easier
* TiKV and TiDB can use any existing TiKV to join the cluster
* We can expose TiKV as a service, so no tikv-proxy is needed for applications use TiKV directly

``` shell
# Create a bridged network
docker network create -d bridge hackathon

# Start TiKV
docker run -d --net=hackathon --name=tikv-1 -v $PWD/tikv-1:/data hackathon /tikv-server init --node=tikv-1

docker run -d --net=hackathon --name=tikv-2 -v $PWD/tikv-2:/data hackathon /tikv-server join tikv-1 --node=tikv-2

docker run -d --net=hackathon --name=tikv-3 -v $PWD/tikv-3:/data hackathon /tikv-server join tikv-1 --node=tikv-3

docker run -d --net=hackathon --name=tikv-4 -v $PWD/tikv-4:/data hackathon /tikv-server join tikv-3 --node=tikv-4

# Start TiDB
docker run -d --net=hackathon --name=tidb-1 hackathon /tidb-server --path=tikv-1:2379

docker run -d --net=hackathon --name=tidb-2 hackathon /tidb-server --path=tikv-4:2379

# If we add a LB in front of all tikv-servers with domain name of `tikv`
# Then tidb-server can use the `tikv` service to join the cluster
docker run -d --net=hackathon --name=tidb-3 hackathon /tidb-server --path=tikv:2379
```
