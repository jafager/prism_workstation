#!/bin/bash


ansible monlabcp1 -m kubernetes.core.helm -a "name=prom-operator release_namespace=prom-operator state=absent kubeconfig=/etc/kubernetes/admin.conf wait=true"

for pvc in `kubectl get pvc -n prom-operator | awk '{print $1}' | grep -v NAME`
do
    kubectl delete pvc $pvc -n prom-operator
done

for pvc in `kubectl get pvc -n prometheus | awk '{print $1}' | grep -v NAME`
do
    kubectl delete pvc $pvc -n prometheus
done
