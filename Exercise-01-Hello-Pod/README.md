# Exercise 1 – Hello Pod

## Aim
Run Zepto's storefront / delivery-status web app (simulated with the `nginx`
image) inside Kubernetes as a Pod, expose it with a NodePort Service, and open
it in the browser.

## Environment
| Item | Value |
|------|-------|
| Cluster | Minikube (single node), Docker driver |
| CLI | kubectl |
| Image | `nginx` (Docker Hub, latest) |
| Pod / Service name | `hello-k8s` |

## Files
| File | Purpose |
|------|---------|
| `run.sh` | The five prescribed commands, plus readiness wait, HTTP check and `describe`; logs to `outputs/run-output.txt` |
| `run-declarative.sh` | Same result via `kubectl apply -f` on the YAML manifests |
| `manifests/pod.yaml` | Pod definition equivalent to `kubectl run` |
| `manifests/service.yaml` | NodePort Service equivalent to `kubectl expose` |
| `cleanup.sh` | Deletes the Pod and Service (`--stop` also stops Minikube) |
| `outputs/` | Captured terminal log and browser screenshot |

## Prerequisites (one-time)
Linux / WSL:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
macOS: `brew install minikube` · Windows (admin PowerShell): `choco install minikube`

Docker (or a VM driver such as VirtualBox / Hyper-V) must be installed and running.
If `kubectl` is not installed, `minikube kubectl -- <args>` works as a drop-in.

## Steps performed

```bash
# 1. Start a local Kubernetes cluster
minikube start

# 2. Create the Pod from the nginx image, declaring container port 80
kubectl run hello-k8s --image=nginx --port=80

# 3. Verify the Pod is running
kubectl get pods

# 4. Expose the Pod as a NodePort Service
kubectl expose pod hello-k8s --type=NodePort --port=80

# 5. Open the app in the browser
minikube service hello-k8s
```

Or run everything with logging: `chmod +x *.sh && ./run.sh`

## Expected output

```text
$ kubectl get pods
NAME        READY   STATUS    RESTARTS   AGE
hello-k8s   1/1     Running   0          30s

$ kubectl get svc hello-k8s
NAME        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
hello-k8s   NodePort   10.x.x.x        <none>        80:3XXXX/TCP   10s
```

The browser shows **"Welcome to nginx!"**. The real log and screenshot from my
run are in [`outputs/`](outputs/).

## What happens internally (system internal details)

1. **`minikube start`** creates one node (a Docker container or VM) running the
   control plane (API server, etcd, scheduler, controller-manager) and the
   worker components (kubelet, kube-proxy, container runtime). It also writes
   the `minikube` context into `~/.kube/config` so kubectl talks to it.
2. **`kubectl run`** sends a Pod object to the **API server**, which validates
   it and stores it in **etcd**. Status is `Pending`.
3. The **scheduler** sees an unscheduled Pod and binds it to the node.
4. The **kubelet** on that node asks the container runtime to pull `nginx` and
   start the container (status `ContainerCreating` → `Running`). The Pod gets
   its own cluster IP.
5. **`kubectl expose`** creates a **Service** whose selector is the Pod's label
   `run=hello-k8s`. The endpoints controller records the Pod IP as an endpoint.
6. `type=NodePort` makes **kube-proxy** program iptables rules so that
   `<NodeIP>:<NodePort>` → Service port 80 → Pod port 80.
7. **`minikube service`** looks up the node IP + NodePort and opens that URL
   (with the Docker driver on macOS/Windows/WSL it runs a local tunnel – keep
   that terminal open).

Request path: `Browser → NodeIP:NodePort → kube-proxy rules → Service :80 → Pod :80 → nginx`

## Troubleshooting notes
| Symptom | Cause | Fix |
|---------|-------|-----|
| `minikube start` fails: driver not found | Docker not running | Start Docker Desktop / `sudo systemctl start docker`, then `minikube start --driver=docker` |
| Pod stuck in `ImagePullBackOff` / `ErrImagePull` | No internet or image name typo | `kubectl describe pod hello-k8s` → check Events; fix network or image name, delete and recreate |
| Pod stuck in `Pending` | Node not ready / low resources | `kubectl get nodes`, `kubectl describe pod hello-k8s` |
| `Error from server (AlreadyExists)` | Re-running the exercise | `./cleanup.sh` then run again |
| Browser can't open the NodePort URL on WSL / Mac | Docker driver networking | Use `minikube service hello-k8s` and keep the terminal open, or `kubectl port-forward pod/hello-k8s 8080:80` and open `localhost:8080` |
| Service has no endpoints | Selector doesn't match Pod label | `kubectl get pods --show-labels` vs `kubectl describe svc hello-k8s` |

## Cleanup
```bash
./cleanup.sh          # delete Pod + Service
./cleanup.sh --stop   # also stop Minikube
```

## Viva quick notes
- **Pod** – smallest deployable unit in Kubernetes; one or more containers sharing network namespace and storage. Here: one nginx container.
- **Why a Service?** Pod IPs are internal and change when a Pod is recreated. A Service gives a stable IP/DNS name and load-balances to matching Pods via labels.
- **Service types** – `ClusterIP` (internal only, default), `NodePort` (opens 30000–32767 on every node), `LoadBalancer` (cloud LB), `ExternalName` (DNS alias).
- **`--port=80` on `kubectl run`** only documents the container port; it does not publish anything. Exposure is done by the Service.
- **port vs targetPort vs nodePort** – Service port (80) / container port (80) / port opened on the node (auto, 30000–32767).
- **Limitation of a bare Pod** – if it's deleted or the node dies, nothing recreates it, and it can't scale. For "always running and scalable" (the Zepto requirement) the next step is a **Deployment** with replicas.
- **Imperative vs declarative** – `kubectl run/expose` vs `kubectl apply -f *.yaml`. Declarative YAML is version-controlled and repeatable, which is why both are in this repo.
- **Useful debug commands** – `kubectl describe pod`, `kubectl logs hello-k8s`, `kubectl get events --sort-by=.lastTimestamp`, `kubectl exec -it hello-k8s -- sh`.
