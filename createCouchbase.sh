#!/bin/bash

export NAMESPACE=couchbase-cluster
export STORAGECLASSNAME=sc-couchbase
export SECRETNAME=couchbase-administrator

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

printf "enter the couchbase administrator cluster username:"
read USERNAME

stty -echo
printf -n "enter the couchbase administrator cluster password:"
read PASSWORD
stty echo


USERNAME=$(echo -n $USERNAME | base64)
PASSWORD=$(echo -n $PASSWORD | base64)

kubectl delete secret SECRETNAME -n "$NAMESPACE"

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
        namespace: ${NAMESPACE}
        name: ${SECRETNAME}
type: Opaque
data:
        username: ${USERNAME}
        password: ${PASSWORD}
EOF

kubectl apply -f https://raw.githubusercontent.com/justdomepaul/couchbase-cluster-kubernetes/master/couchbase-statefulset.yml