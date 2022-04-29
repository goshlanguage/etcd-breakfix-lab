#!/bin/bash

# kill etcd process on node2
docker exec $(docker ps | grep kind-control-plane2 | awk '{print $1}') bash -c "ps awwfux|grep \"[\]_ etcd\"|awk '{print \$2}'|xargs kill -9 ";

# remove etcd member on node3
docker exec $(docker ps | grep kind-control-plane2 | awk '{print $1}') bash -c "source /root/.bashrc; etcdctl member list";
docker exec $(docker ps | grep kind-control-plane3 | awk '{print $1}') bash -c "source /root/.bashrc; etcdctl member list";

# big yikes, can we recover?
kubectl get node
