#!/usr/bin/env bash
# Exercise 2 - Flask app on Minikube (Linux / WSL / macOS / Git Bash)
# Usage (from inside Exercise-02-Flask-on-Minikube):  ./run.sh
set -euo pipefail
mkdir -p outputs
exec > >(tee outputs/run-output.txt) 2>&1
step() { echo; echo "===== $* ====="; }

step "Step 1: Start Minikube"
minikube start --driver=docker
kubectl cluster-info

step "Step 4: Use Minikube's Docker daemon and build the image"
minikube docker-env
eval "$(minikube docker-env)"
docker build -t flask-app .
docker images flask-app

step "Step 5-6: Apply Deployment-only YAML"
kubectl apply -f steps/flask-deployment-step5.yaml
kubectl rollout status deployment/flask-app --timeout=120s

step "Step 7: Deployments";            kubectl get deployments
step "Step 8: Pods";                   kubectl get pods -l app=flask-app
step "Step 9: Describe Deployment";    kubectl describe deployment flask-app
step "Step 10: Logs";                  kubectl logs deployment/flask-app
step "Step 11: Services";              kubectl get services

step "Step 12: Direct access fails (expected)"
curl -s --max-time 3 http://127.0.0.1:15000 || echo "Expected failure: port 15000 not exposed outside the cluster"

step "Step 13: Apply Deployment + Service YAML"
kubectl apply -f flask-deployment.yaml
kubectl get services

step "Access via minikube service"
URL="$(minikube service flask-app-service --url | head -1)"
echo "URL: $URL"
curl -s "$URL"; echo
