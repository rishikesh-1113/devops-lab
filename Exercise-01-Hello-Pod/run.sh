#!/usr/bin/env bash
# Exercise 1 – Hello Pod (imperative way, exactly as prescribed)
# Usage:  ./run.sh            (from inside Exercise-01-Hello-Pod/)
# Everything printed is also saved to outputs/run-output.txt for the repo.

set -euo pipefail

OUT="outputs/run-output.txt"
mkdir -p outputs
exec > >(tee "$OUT") 2>&1

step() { echo; echo "===== $* ====="; }

step "Tool versions"
minikube version
kubectl version --client

step "1. Start the local cluster"
minikube start --driver=docker
kubectl get nodes -o wide

step "2. Create the Pod (nginx = Zepto storefront)"
kubectl run hello-k8s --image=nginx --port=80

step "3. Wait for the Pod to become Ready, then list it"
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=180s
kubectl get pods -o wide

step "4. Expose the Pod as a NodePort Service"
kubectl expose pod hello-k8s --type=NodePort --port=80
kubectl get svc hello-k8s
kubectl get endpoints hello-k8s

step "5. Verify the app responds (HTTP check)"
URL="$(minikube service hello-k8s --url)"
echo "Service URL: $URL"
curl -s "$URL" | grep -i "<title>"

step "Internal details (for explanation / viva)"
kubectl describe pod hello-k8s
kubectl describe svc hello-k8s

echo
echo "Done. Open it in the browser with:  minikube service hello-k8s"
echo "Output saved to $OUT"
