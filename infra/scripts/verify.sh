#!/usr/bin/env bash
set -euo pipefail
kubectl get nodes -o wide
kubectl wait --for=condition=Ready pods --all --timeout=180s --all-namespaces
kubectl run nats-smoke --rm -i --restart=Never --namespace messaging --image=natsio/nats-box:latest \
  -- /bin/sh -c "nats server check jetstream || nats -s nats://nats:4222 sub foo & sleep 2 && nats -s nats://nats:4222 pub foo 'hello'"
kubectl -n data exec deploy/fdb-kubernetes-operator-controller-manager -- fdbcli --exec "status minimal"
kubectl -n data run scylla-nodecheck --rm -i --restart=Never --image=scylladb/scylla:5.4 \
  -- bash -c "nodetool status"
