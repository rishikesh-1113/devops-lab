# DevOps Laboratory – Hands-On Exercises

Lab repository for the DevOps course (BMSCE, Information Science & Engineering).
Each exercise lives in its own numbered folder with its code, manifests or pipeline
definitions, screenshots of the run, and a README write-up.

**Scenario used throughout:** DevOps engineer at a quick-commerce company (Zepto-style)
building, shipping, securing and monitoring its storefront, flash-sale and delivery services.

The exercises cover four areas:

- **Kubernetes** – Pods, Services, Deployments, ReplicaSets, multi-node clusters (Minikube)
- **Docker** – multi-container networking and container security with AppArmor
- **CI/CD** – Jenkins Freestyle jobs and multi-stage Pipelines driven from this repo
- **Observability** – Prometheus metrics, alert rules and Grafana dashboards

## Exercises

| # | Exercise | Area | Folder | Status |
|---|----------|------|--------|--------|
| 1 | Hello Pod – run nginx as a Pod and expose it with a NodePort Service | Kubernetes | [Exercise-01-Hello-Pod](Exercise-01-Hello-Pod/) | Done |
| 2 | Deploy a Flask app on Minikube using kubectl and YAML (Deployment + Service) | Kubernetes | [Exercise-02-Flask-on-Minikube](Exercise-02-Flask-on-Minikube/) | Done |
| 3 | Scale a Flask flash-sale app on a single node with a ReplicaSet (scaling, self-healing, probes) | Kubernetes | [Exercise-03-Flask-ReplicaSet](Exercise-03-Flask-ReplicaSet/) | Done |
| 4 | Docker networking – Flask, MySQL and Redis containers on a user-defined bridge network | Docker | [Exercise-04-Docker-Networking](Exercise-04-Docker-Networking/) | Done |
| 5 | Docker security – run a Flask container under a custom AppArmor profile, automated with the Docker SDK for Python | Docker / Security | [Exercise-05-Docker-AppArmor](Exercise-05-Docker-AppArmor/) | Done |
| 6 | Real-time delivery monitoring – Python metrics exporter, Prometheus alerts, Grafana dashboard, Jenkins check | Observability | [Exercise-06-Delivery-Monitoring](Exercise-06-Delivery-Monitoring/) | Done |
| 7 | Continuous Integration fundamentals and a first Jenkins Pipeline | CI/CD | [Exercise-07-Jenkins-CI-Automation](Exercise-07-Jenkins-CI-Automation/) | Done |
| 8 | "Hello World" Jenkins Freestyle job pulling a script from this GitHub repo | CI/CD | [Exercise-08-Jenkins-Hello-World-Job](Exercise-08-Jenkins-Hello-World-Job/) | Done |
| 9 | Jenkins multi-stage Pipeline (Build → Test → Deploy → Run → Test App) for a Flask app | CI/CD | [Exercise-09-Jenkins-Multistage-Pipeline](Exercise-09-Jenkins-Multistage-Pipeline/) | Done |
| 10 | Multi-node Kubernetes – Product Catalog (2 replicas) and Shopping Cart (3 replicas) spread across a 3-node cluster | Kubernetes | [Exercise-10-Multinode-Kubernetes](Exercise-10-Multinode-Kubernetes/) | Done |

## Repository layout

```
.
├── README.md
├── .gitignore
├── Exercise-01-Hello-Pod/
│   ├── README.md                 # aim, steps, explanation, verification, viva notes
│   ├── run.sh                    # imperative steps (kubectl run / expose)
│   ├── run-declarative.sh        # same result using YAML manifests
│   ├── cleanup.sh
│   ├── manifests/                # pod.yaml, service.yaml
│   └── outputs/
├── Exercise-02-Flask-on-Minikube/
│   ├── README.md                 # steps, explanation, troubleshooting, Q&A
│   ├── app.py, Dockerfile, .dockerignore
│   ├── flask-deployment.yaml     # Deployment + NodePort Service (final)
│   ├── steps/flask-deployment-step5.yaml   # Deployment only
│   ├── run.ps1 / run.sh / cleanup.sh
│   └── outputs/
├── Exercise-03-Flask-ReplicaSet/
│   ├── README.md
│   ├── app.py, Dockerfile        # flashsale:1.0 – /, /buy, /health
│   ├── flashsale-replicaset.yaml # ReplicaSet (3 replicas) + ClusterIP Service
│   └── *.png                     # nodes, replicaset, pods-wide, requests, self-healing
├── Exercise-04-Docker-Networking/
│   ├── README.md
│   ├── app.py, requirements.txt, Dockerfile   # flask-api on port 5001
│   └── *.png                     # network, containers, network-members, ping
├── Exercise-05-Docker-AppArmor/
│   ├── README.md
│   ├── app.py, requirements.txt, Dockerfile
│   └── apply_apparmor.py         # Docker SDK: build, run with profile, verify, clean up
├── Exercise-06-Delivery-Monitoring/
│   ├── README.md
│   ├── delivery_metrics.py       # prometheus_client exporter on :8000
│   ├── prometheus.yml            # scrape config (5s)
│   ├── alert_rules.yml           # pending-deliveries / delivery-time alerts
│   ├── Jenkinsfile               # pipeline that checks the monitoring setup
│   └── *.png                     # targets, alerts, Grafana dashboard, Jenkins console
├── Exercise-07-Jenkins-CI-Automation/
│   ├── Readme.md
│   ├── Jenkinsfile
│   └── console-output*.png
├── Exercise-08-Jenkins-Hello-World-Job/
│   ├── README.md
│   ├── hello-world.sh
│   └── build-summary.png, console-output.png
├── Exercise-09-Jenkins-Multistage-Pipeline/
│   ├── README.md
│   ├── app.py, test_app.py, requirements.txt
│   ├── Jenkinsfile               # Build, Test, Deploy, Run Application, Test Application
│   └── stage-view.png, build-summary.png, console-output.png
└── Exercise-10-Multinode-Kubernetes/
    ├── README.md
    ├── product_catalog.py, shopping_cart.py
    ├── Dockerfile.product, Dockerfile.shopping
    ├── product_catalog_deployment.yaml, product_catalog_service.yaml
    ├── shopping_cart_deployment.yaml, shopping_cart_service.yaml
    └── *.png                     # nodes, pods, services, curl-tests
```

## Tooling

| Tool | Used in |
|------|---------|
| Minikube (Docker driver; single-node and 3-node profiles) | 1, 2, 3, 10 |
| kubectl | 1, 2, 3, 10 |
| Docker | all exercises |
| Python 3 / Flask | 2, 3, 4, 5, 6, 9, 10 |
| MySQL, Redis (containers) | 4 |
| AppArmor, Docker SDK for Python (Ubuntu) | 5 |
| Prometheus, Grafana | 6 |
| Jenkins (LTS, run in Docker) | 6, 7, 8, 9 |

## Running an exercise

Each folder is self-contained: open its README and follow the steps in order.
Jenkins jobs (Exercises 6–9) use this repository as their SCM source
(`https://github.com/rishikesh-1113/devops-lab.git`, branch `main`) with the
script path pointing into the relevant exercise folder.

No credentials, kubeconfigs or API keys are committed to this repository
(see `.gitignore`).
