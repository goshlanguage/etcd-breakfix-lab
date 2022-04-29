#!/bin/bash

kind create cluster --config ./kind.conf

docker ps | grep kind-control-plane | awk '{print $1}' | while read POD;
  do
    docker exec $POD curl -L https://storage.googleapis.com/etcd/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz -o /tmp/etcd.tar.gz;
    docker exec $POD tar zxvf /tmp/etcd.tar.gz -C /usr/local/bin/ --strip-components=1;
    docker exec $POD bash -c 'echo "export ETCDCTL_API=3" >> /root/.bashrc';
    docker exec $POD bash -c 'echo "export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt" >> /root/.bashrc';
    docker exec $POD bash -c 'echo "export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/healthcheck-client.crt" >> /root/.bashrc';
    docker exec $POD bash -c 'echo "export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/healthcheck-client.key" >> /root/.bashrc';
  done;
