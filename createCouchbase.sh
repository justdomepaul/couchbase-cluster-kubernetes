#!/bin/bash

export COUCHBASE_CLUSTER_NAME=couchbase-cluster
export STORAGECLASSNAME=sc-couchbase

kubectl create namespace "$NAMESPACE"

kubectl delete sc $STORAGECLASSNAME

cat <<EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
        name: ${STORAGECLASSNAME}
parameters:
        type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: Immediate
EOF

kubectl apply -f https://raw.githubusercontent.com/justdomepaul/couchbase-cluster-kubernetes/master/deploy/couchbase-statefulset.yml