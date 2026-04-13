# Secure Log Aggregator (Kubernetes Portfolio Project)

A cloud-agnostic, self-healing log monitoring service built with **Go** and deployed on **Kubernetes**. This project demonstrates **Infrastructure as Code**, **Security-First Design**, and **Operational Best Practices** in a modern cloud-native environment.

## 🏗️ Architecture Overview

- **Language**: Go (compiled statically for Alpine Linux)
- **Orchestration**: Kubernetes (Kind for local development)
- **Security**: Non-root user, NetworkPolicies (deny-all ingress), Resource Limits
- **Reliability**: Liveness/Readiness probes, Horizontal Pod Autoscaler (HPA)
- **Configuration**: ConfigMaps for environment variables

## 🚀 Quick Start

### Prerequisites
- Docker 
- Kind (Kubernetes in Docker)
- kubectl

### 1. Build the Image
```bash
docker build -t log-aggregator:latest .

2. Run Locally (Docker)

docker run --rm -e ERROR_PATTERN="CRITICAL" log-aggregator:latest
3. Deploy to Kubernetes (Kind)

# Create a local cluster
kind create cluster

# Load the local image into the cluster
kind load docker-image log-aggregator:latest

# Apply Kubernetes manifests
kubectl apply -f k8s/

# Verify pods are running
kubectl get pods

# View logs
kubectl logs -f deployment/log-aggregator
🔒 Security Features
This project prioritizes security at every layer:

Feature			Implementation
-------			--------------
Non-Root User		Container runs as appuser (UID 1000), preventing privilege escalation.
NetworkPolicies		Deny-all ingress by default; allows only outbound HTTPS (port 443) for potential webhooks.
Resource Limits		CPU: 200m, Memory: 128Mi (prevents runaway pods and DoS).
Immutable Tags		Uses specific image digests in production (avoids :latest drift).
Minimal Base Image	Alpine Linux reduces attack surface and image size (~30MB).

📈 Scalability & Reliability
Horizontal Pod Autoscaler (HPA): Automatically scales from 2 to 5 replicas based on CPU utilization (>50% threshold).

Health Probes:
Liveness: Restarts the pod if the process hangs.
Readiness: Prevents traffic routing until the pod is fully initialized.
Metrics Server: Configured with --kubelet-insecure-tls for local development metrics scraping.

🧪 Testing & Validation:

Simulate Load
To trigger autoscaling, you can simulate high CPU usage (requires stress tool inside the pod):

# Exec into a pod
kubectl exec -it <pod-name> -- sh

# Install stress (if not present) and run a load test
apk add --no-cache stress
stress --cpu 4 --timeout 60s

#Watch the HPA react:
kubectl get hpa -w


🛠️ Technical Challenges & Lessons Learned

Building this project involved solving real-world infrastructure problems:

Go Module Handling: Implemented a robust Dockerfile pattern (cp go.sum ... || true) to handle cases where go.sum is missing (no external dependencies), ensuring builds don't fail on clean environments.
Cgroup Compatibility: Resolved Kind cluster creation failures caused by Docker/Podman transitions and cgroup v2 mismatches by ensuring the systemd cgroup driver.
Metrics Server TLS: Overcame local cluster limitations by configuring the Metrics Server with --kubelet-insecure-tls to bypass self-signed certificate errors from the Kubelet.
RBAC Cleanup: Diagnosed and resolved stale RBAC permissions that blocked deployment rollouts in kube-system.
In K8s deployment definition, ImagePull Should be set to "Never" in non-prod environments to prevent app version changes during testing. In prod, it should be set to "Always", pulling the latest containerized app versions from a predefined repository.


📂 Project Structure

.
├── cmd/
│   └── aggregator/
│       └── main.go          # Entry point
├── pkg/
│   └── monitor/
│       └── monitor.go       # Log pattern matching logic
├── k8s/
│   ├── configmap.yaml       # Environment configuration
│   ├── deployment.yaml      # Pod spec, probes, resources
│   ├── service.yaml         # ClusterIP service
│   ├── networkpolicy.yaml   # Security: Deny ingress, allow egress
│   └── hpa.yaml             # Auto-scaling configuration
├── Dockerfile               # Multi-stage build
├── Makefile                 # Build and deploy automation
└── README.md

🤝 Contributing
This is a portfolio project demonstrating Systems Engineering best practices. Feedback on security configurations, Go idioms, or Kubernetes patterns is welcome!

Built by Andre Parrish | Senior Systems Engineer Contact: andre.t.parrish@gmail.com | LinkedIn 
