#!/bin/bash
set -x -eo pipefail

kubectl get crd | grep compliance > /dev/null
if [[ $? != 0 ]]; then
    echo "Error: Cluster does not have compliance CRDs installed. Exiting."
    exit 1
fi

script_dir=$(realpath $(dirname $0))

# Set the directory where you want to store your YAML files
output_dir="$script_dir/crd_exports"
mkdir -p "$output_dir"

# File to store all CRD definitions containing "compliance"
all_compliance_crds="${script_dir}/all_compliance_crds.yaml"

# Reset the file to ensure it's empty before starting
> "$all_compliance_crds"

# Find all CRDs that contain the word "compliance" and export them to a single YAML file
kubectl get crd -o name | grep "compliance" | while read -r crd_name; do
    kubectl get "$crd_name" -o yaml >> "$all_compliance_crds"
    echo "---" >> "$all_compliance_crds" # Separator for YAML documents
done
echo "Exported CRD definitions to $all_compliance_crds"

# Export all instances of the CRDs into separate YAML files
kubectl get crd -o name | grep "compliance" | while read -r crd_name; do
    crd_group=$(kubectl get "$crd_name" -o jsonpath='{.spec.group}')
    resource_plural=$(kubectl get "$crd_name" -o jsonpath='{.spec.names.plural}')

    # Directory for this CRD's instances
    instance_file="$output_dir/$resource_plural.yaml"
    kubectl get "${resource_plural}.${crd_group}" -n openshift-compliance -o json | jq '.items |= map(del(.metadata.ownerReferences))' > $instance_file

    echo "Exported instances of $crd_name to $crd_dir"
done

echo "All exports completed."
