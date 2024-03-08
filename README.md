# Fake Compliance Operator

Import compliance operator resource into your local cluster for development purposes.

## Import

1. Create a local cluster via colima, kind or similar.
2. Install StackRox
3. Create a compliance scan schedule in Central with the name `compliance-scan-schedule`
4. Apply compliance-operator resources `./apply.sh`
5. Restart Sensor `kubectl delete -n stackrox pod -l app=sensor`

## Export

 - Create an Openshift 4.x cluster from https://infra.rox.systems/
 - Once that is started download the artifacts `infractl artifacts <cluster-name> --download-dir <path>`.
 - Set the kubeconfig `KUBECONFIG <path>/kubeconfig`.
 - Clone compliance operator repository and install compliance operator.
   ```
   git clone https://github.com/ComplianceAsCode/compliance-operator
   cd compliance-operator
   oc create -f config/catalog/catalog-source.yaml
   oc get catalogsource -n openshift-marketplace
   oc create -f config/ns/ns.yaml
   oc create -f config/catalog/operator-group.yaml
   oc create -f config/catalog/subscription.yaml
   ```
 - Deploy StackRox
 - Create a compliance v2 scan schedule
 - Wait until the compliance results are reported in the StackRox UI
 - Execute `./dump-compliance-operator.sh`
