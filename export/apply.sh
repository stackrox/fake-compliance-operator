#!/usr/bin/env bash
set -eo pipefail -x

script_dir=$(realpath $(dirname $0))

kubectl create ns openshift-compliance

kubectl apply -f $script_dir/all_compliance_crds.yaml

for dir in $(ls -l $script_dir/manifests); do
    echo "Processing directory: $dir"
    kubectl apply -f $dir/.
done
