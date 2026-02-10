# Plan: Install K3s + NVIDIA GPU Operator on DGX Spark

## Objective
Set up Kubernetes (K3s) with GPU support on DGX Spark for deploying the agent-skill-adapter stack (TGI, backend, frontend) via Helm charts with NGINX Ingress routing.

## Steps
1. Configure Docker NVIDIA runtime as default on Spark
2. Install K3s with Docker runtime (--docker --disable=traefik)
3. Configure kubectl/KUBECONFIG
4. Install NVIDIA GPU Operator v25.10.1 via Helm (driver+toolkit disabled, already installed)
5. Verify GPU access in K8s (nvidia.com/gpu allocatable)
6. Install NGINX Ingress Controller
7. Create ingress Helm chart (charts/ingress/) with path-based routing
8. Create docs/06_kubernetes_setup.md
9. Update CLAUDE.md files with K8s context
10. Deploy TGI + full stack on K8s
11. Commit and push

## Key Details
- DGX Spark: GB10 GPU, Ubuntu 24.04, CUDA 13.0, 125GB unified RAM
- GPU Operator must be v25.10.0+ for GB10 support
- K3s uses Docker (not containerd) for NVIDIA runtime compatibility
- Ingress routes: /skill-adapter-frontend, /skill-adapter-api, /skill-adapter-inference

## Started
2026-02-07
