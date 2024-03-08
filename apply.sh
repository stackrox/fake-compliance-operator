#!/usr/bin/env bash
set -eo pipefail -x

script_dir=$(realpath $(dirname $0))

kubectl create ns openshift-compliance || true

# Create a fake compliance-operator deployment to report a healthy state in StackRox
kubectl create deployment compliance-operator --image=ubuntu:latest || true

# The following resources are created by Sensor
# kubectl apply -f $script_dir/crd_exports/scansettingbindings.yaml
# kubectl apply -f $script_dir/crd_exports/scansettings.yaml.yaml

initialize() {
    kubectl apply -f $script_dir/all_compliance_crds.yaml
    kubectl apply -f $script_dir/crd_exports/compliancescans.yaml
    kubectl apply -f $script_dir/crd_exports/compliancesuites.yaml
    kubectl apply -f $script_dir/crd_exports/profilebundles.yaml
    kubectl apply -f $script_dir/crd_exports/profiles.yaml
    kubectl apply -f $script_dir/crd_exports/profiles.yaml
    kubectl apply -f $script_dir/crd_exports/tailoredprofiles.yaml
    kubectl apply -f $script_dir/crd_exports/variables.yaml

    kubectl delete pod -l app=sensor -n stackrox
}

import_results() {
 kubectl apply -f $script_dir/crd_exports/compliancecheckresults.yaml
}

# Main script logic
case $1 in
  init)
    initialize
    ;;
  scan)
    import_results
    ;;
  all)
    init_function
    import_results
    ;;
  *)
    echo "Unknown command: $1"
    echo "Usage: $0 {init|scan|all}"
    exit 1
    ;;
esac
