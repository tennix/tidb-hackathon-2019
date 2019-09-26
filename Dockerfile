FROM centos:7

ADD tikv/target/debug/tikv-server /tikv-server
ADD tidb/bin/tidb-server /tidb-server
