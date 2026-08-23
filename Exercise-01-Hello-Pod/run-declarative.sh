#!/usr/bin/env bash
# Exercise 1 – same result as run.sh, but declarative (YAML manifests).
# Run cleanup.sh first if the imperative objects already exist.

set -euo pipefail

mkdir -p outputs
exec > >(tee outputs/run-declarative-output.txt) 2>&1

minikube status >/dev/null 2>&1 || minikube start --driver=docker

kubectl apply -f manifests/pod.yaml
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=180s
kubectl apply -f manifests/service.yaml

kubectl get pod/hello-k8s svc/hello-k8s -o wide
URL="$(minikube service hello-k8s --url)"
echo "Service URL: $URL"
curl -s "$URL" | grep -i "<title>"
