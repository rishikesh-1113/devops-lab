# DevOps Laboratory – Kubernetes Hands-On Exercises

Lab repository for the DevOps course (BMSCE, Information Science & Engineering).
Each exercise lives in its own numbered folder with its scripts, manifests,
captured output and a write-up.

**Scenario used throughout:** DevOps engineer at Zepto deploying the customer
storefront / delivery-status web app on Kubernetes (simulated with `nginx`).

## Exercises

| # | Exercise | Folder | Status |
|---|----------|--------|--------|
| 1 | Hello Pod – run nginx as a Pod and expose it with a NodePort Service | [Exercise-01-Hello-Pod](Exercise-01-Hello-Pod/) | Done |

## Repository layout

```
.
├── README.md
└── Exercise-01-Hello-Pod/
    ├── README.md            # aim, steps, explanation, verification, viva notes
    ├── run.sh               # imperative steps exactly as in the exercise
    ├── run-declarative.sh   # same result using YAML manifests
    ├── cleanup.sh           # removes everything the exercise created
    ├── manifests/
    │   ├── pod.yaml
    │   └── service.yaml
    └── outputs/             # terminal output + screenshot captured while running
```

## Tooling

- Minikube (local single-node cluster, Docker driver)
- kubectl
- Docker

No credentials, kubeconfigs or API keys are committed to this repository.
