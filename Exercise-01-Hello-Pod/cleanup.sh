#!/usr/bin/env bash
# Remove everything Exercise 1 created. Pass --stop to also stop minikube.
set -uo pipefail

kubectl delete service hello-k8s --ignore-not-found
kubectl delete pod hello-k8s --ignore-not-found
kubectl get pods,svc

if [[ "${1:-}" == "--stop" ]]; then
  minikube stop
fi
