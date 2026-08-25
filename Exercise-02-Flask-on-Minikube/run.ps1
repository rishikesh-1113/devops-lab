# Exercise 2 - Flask app on Minikube (Windows PowerShell version)
# Usage (from inside Exercise-02-Flask-on-Minikube):
#   powershell -ExecutionPolicy Bypass -File .\run.ps1
# Output is saved to outputs\run-output.txt

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path outputs | Out-Null
Start-Transcript -Path outputs\run-output.txt -Force | Out-Null

function Step($t) { Write-Host "`n===== $t =====" -ForegroundColor Cyan }

Step "Step 1: Start Minikube"
minikube start --driver=docker
kubectl cluster-info

Step "Step 4: Point Docker CLI at Minikube's Docker daemon and build the image"
minikube docker-env --shell powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker build -t flask-app .
docker images flask-app

Step "Step 5-6: Apply Deployment-only YAML"
kubectl apply -f steps\flask-deployment-step5.yaml
kubectl rollout status deployment/flask-app --timeout=120s

Step "Step 7: Deployments"
kubectl get deployments

Step "Step 8: Pods created by the Deployment"
kubectl get pods -l app=flask-app

Step "Step 9: Describe Deployment"
kubectl describe deployment flask-app

Step "Step 10: Logs"
kubectl logs deployment/flask-app

Step "Step 11: Services (no flask service yet)"
kubectl get services

Step "Step 12: Direct access fails (expected)"
try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 http://127.0.0.1:15000 | Out-Null }
catch { Write-Host "Expected failure: $($_.Exception.Message)" }

Step "Step 13: Apply Deployment + Service YAML"
kubectl apply -f flask-deployment.yaml
kubectl get services

Write-Host "`nNow run in THIS terminal (keep it open):  minikube service flask-app-service --url"
Write-Host "Then in a NEW terminal:                     curl.exe <that URL>"
Stop-Transcript | Out-Null
