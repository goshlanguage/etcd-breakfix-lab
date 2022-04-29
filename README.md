# etcd-lab

It's that time again, to break the internet for fun and profit.

![lets break the internet](https://media.giphy.com/media/QzutKz3TC57KNEV2Xp/giphy.gif)

This lab is a breakfix scenario for etcd. In this lab, we bring up a healthy running cluster, and replicate an incident where when replacing a node for upgrade, we remove another etcd member, leaving us with 1 etcd working... and maybe recover it.

To run this lab, you'll need a running container runtime, and `kind`. If you don't have `kind`, it can be installed with `brew install kind` or fetch the binary from the [github releases page](https://github.com/kubernetes-sigs/kind/releases).

## Setup

The lab setup exists in a bash script for convenience, to start run:

`bash start.sh`

We should now have a currently working, happy, healthy `kubernetes` cluster. Let's burn it down. Wave one last time to `kubectl` if you like.

`bash bork.sh`

There remains 1 running etcd process on `kind-control-plane`, can you reconfigure this etcd process to come up cleanly and rejoin the rest of the cluster?

> NOTE: This script isn't working yet, something to do with trying to run everything through exec. We can follow the following steps though

exec into node 3, remove member 2

```
docker exec -ti $(docker ps | grep kind-control-plane3 | awk '{print $1}') bash

MEMBER=$(etcdctl member list | grep kind-control-plane2 | awk '{print $1}'|cut -d, -f1);
etcdctl member remove ${MEMBER};
mv /etc/kubernetes/manifests/etcd.yaml /root/
ps awwfux|grep "[\]_ etcd"|awk '{print $2}'| xargs kill -9
exit

kubectl get no
```

Is it broken?

## Tips for working with this lab

`kind` runs its node abstraction as containers. You can exec into these containers to emulate SSHing into a control plane node.

These containers have a working `systemd` as PID 1, and are configured with `kubeadm`.
The setup script elso pulls down `etcdctl` and sets up the environment for you.

You can jump onto the `nodes` with these helpers:

`kind-control-plane`:

`docker exec -ti $(docker ps | grep kind-control-plane$ | awk '{print $1}') bash`

`kind-control-plane2`:

`docker exec -ti $(docker ps | grep kind-control-plane2 | awk '{print $1}') bash`

`kind-control-plane`:

`docker exec -ti $(docker ps | grep kind-control-plane3 | awk '{print $1}') bash`

`etcd` membership is controlled with the `etcdctl` cli. As a recap these may be helpful to you:

```
etcdctl member list
etcdctl member add -h
etcdctl member update -h
```

## Where do we go from here?

`etcd` is still running on node 1, but without enough members to have quorum. The data still exists on node 1.

- Can etcd on node 1 be reconfigured to serve requests from that member?
- Is there any data left over in etcd from the previous members?
- Can other etcd members be joined?
