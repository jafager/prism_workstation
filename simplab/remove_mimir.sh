#!/bin/bash


ansible simplabcp1 -m kubernetes.core.helm -a "name=mimir release_namespace=mimir state=absent kubeconfig=/etc/kubernetes/admin.conf wait=true"

for pvc in `kubectl --kubeconfig kubeconfig get pvc -n mimir | awk '{print $1}' | grep -v NAME`
do
    kubectl --kubeconfig kubeconfig delete pvc $pvc -n mimir
done
