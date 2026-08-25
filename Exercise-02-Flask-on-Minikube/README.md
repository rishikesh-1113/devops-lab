# Exercise 2 – Deploy a Flask App on Minikube using kubectl and YAML

## Objective
Set up a single-node Kubernetes cluster with Minikube, containerize a Python
Flask app, deploy it with a **Deployment** YAML, and expose it with a
**NodePort Service** so it can be reached from outside the cluster.

## Files
| File | Purpose |
|------|---------|
| `app.py` | Flask app – returns `Hello from Flask on Kubernetes!` on port 15000 |
| `Dockerfile` | Builds the `flask-app` image from `python:3.8-slim` |
| `.dockerignore` | Keeps docs/YAML/scripts out of the image |
| `steps/flask-deployment-step5.yaml` | Step 5 – Deployment only (access fails in Step 12) |
| `flask-deployment.yaml` | Step 13 – Deployment **+** NodePort Service (final) |
| `run.ps1` | All steps for **Windows PowerShell**, logs to `outputs/run-output.txt` |
| `run.sh` | All steps for Linux / WSL / Git Bash |
| `cleanup.sh` | Deletes the Deployment and Service |
| `outputs/` | Terminal log + screenshot from my run |

## Steps performed

### Step 1 – Start Minikube
```bash
minikube start
```

### Step 2 & 3 – Flask app and Dockerfile
See `app.py` and `Dockerfile` in this folder.

### Step 4 – Build the image inside Minikube's Docker daemon
```bash
minikube docker-env                 # shows the variables that will be set
eval $(minikube docker-env)         # Linux / WSL / Git Bash
docker build -t flask-app .
```
Windows PowerShell:
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker build -t flask-app .
```
Building inside Minikube's daemon puts the image directly on the cluster node,
so no registry push is needed.

### Step 5 & 6 – Deployment and apply
```bash
kubectl apply -f steps/flask-deployment-step5.yaml
```
`imagePullPolicy: Never` → use the local `flask-app:latest`, never pull from
Docker Hub (where it doesn't exist).

| Policy | Behaviour |
|--------|-----------|
| `Always` | Always pull from the registry |
| `IfNotPresent` | Pull only if not present locally |
| `Never` | Only use a local image |

### Step 7 – 11 – Verify
```bash
kubectl get deployments                 # flask-app  1/1  1  1
kubectl get pods -l app=flask-app       # STATUS Running
kubectl describe deployment flask-app   # replicas, strategy, events
kubectl logs deployment/flask-app       # "Running on http://0.0.0.0:15000"
kubectl get services                    # only "kubernetes" – no flask service yet
```
(`kubectl logs <pod-name>` also works – copy the name from `get pods`.)

### Step 12 – Direct access fails (expected)
```bash
curl http://127.0.0.1:15000
# curl: (7) Failed to connect to 127.0.0.1 port 15000 ...
```
Minikube runs in its own container/VM; port 15000 exists only inside the Pod
network and nothing exposes it.

### Step 13 – Add a Service and access the app
```bash
kubectl apply -f flask-deployment.yaml
# deployment.apps/flask-app unchanged
# service/flask-app-service created

minikube service flask-app-service --url
# http://127.0.0.1:xxxxx   (keep this terminal open with the Docker driver)

curl http://127.0.0.1:xxxxx           # in a new terminal  (Windows: curl.exe)
# Hello from Flask on Kubernetes!
```

Request path:
`Client → 127.0.0.1:<tunnel> → NodeIP:NodePort → Service :15000 (port) → Pod :15000 (targetPort) → Flask`

## Pod (Exercise 1) vs Deployment (Exercise 2)
| | Bare Pod | Deployment |
|---|---|---|
| Self-healing | No – deleted Pod stays deleted | Yes – ReplicaSet recreates it |
| Scaling | No | `kubectl scale deployment flask-app --replicas=3` |
| Rolling updates / rollback | No | Yes (`RollingUpdate`, `kubectl rollout undo`) |

Object chain: **Deployment → ReplicaSet (`flask-app-<hash>`) → Pod(s) (`flask-app-<hash>-<id>`)**

## Troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
| Pod `ErrImageNeverPull` | Image was built in your normal Docker, not Minikube's | Re-run the `docker-env` step in the **same** terminal, then `docker build` again, then `kubectl rollout restart deployment/flask-app` |
| Pod `CrashLoopBackOff` | Error in `app.py` | `kubectl logs deployment/flask-app` |
| `curl` hangs on Windows | PowerShell `curl` is an alias | Use `curl.exe` or open the URL in a browser |
| URL stops working | `minikube service` terminal closed | Keep that terminal open |
| Service has no endpoints | Selector/label mismatch | `kubectl get endpoints flask-app-service` |

Alternative to docker-env: build normally then `minikube image load flask-app`.

## Cleanup
```bash
kubectl delete -f flask-deployment.yaml
minikube stop
```

## Q&A
1. **Purpose of `minikube service flask-app-service --url`?** Gives the URL to reach the service running in Minikube.
2. **What happens when you run it?** Minikube checks the service exists and is exposed, builds the URL (opening a tunnel with the Docker driver) and prints it.
3. **Why `targetPort`?** It is the port the container listens on (15000).
4. **`port` vs `targetPort`?** `port` = the Service's exposed port; `targetPort` = the container's port. (`nodePort` = port opened on the node, 30000–32767.)
5. **How to access a Flask app in Minikube?** `minikube service <name> --url`, then curl/browser that URL.
6. **Why keep the terminal open (Docker driver)?** The node runs inside a Docker container; Minikube keeps a tunnel open from localhost to it for as long as the command runs.
7. **Benefit of `--url`?** Prints the URL instead of opening a browser, so you don't have to work out node IP + NodePort yourself.
8. **Command to expose a service?** `kubectl expose ...` or `kubectl apply -f <service.yaml>`.
9. **How does Minikube help local testing?** Runs a full single-node cluster on a laptop – no cloud cluster needed.
10. **Role of kubectl?** The Kubernetes CLI – sends requests to the API server to create, inspect, scale and delete resources.
