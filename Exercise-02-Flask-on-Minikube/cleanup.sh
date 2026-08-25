#!/usr/bin/env bash
# Remove everything Exercise 2 created. Pass --stop to also stop Minikube.
set -uo pipefail
kubectl delete -f flask-deployment.yaml --ignore-not-found
kubectl get deployments,pods,services
[[ "${1:-}" == "--stop" ]] && minikube stop
exit 0
