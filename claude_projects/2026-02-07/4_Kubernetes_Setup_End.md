# Kubernetes Setup — Completed

## Work Completed

### K3s Installation (on DGX Spark)
- Installed K3s v1.34.3 with containerd (NOT Docker — Docker CRI doesn't support RuntimeClass)
- K3s auto-detects NVIDIA Container Toolkit and configures the `nvidia` runtime handler
- Disabled Traefik (using NGINX Ingress instead)
- KUBECONFIG added to ~/.bashrc

### NVIDIA GPU Operator v25.10.1
- Installed via Helm with driver.enabled=false, toolkit.enabled=false (both pre-installed)
- All pods running: device-plugin, feature-discovery, dcgm-exporter, validator
- `nvidia.com/gpu: "1"` advertised on node

### NGINX Ingress Controller
- Installed via Helm with LoadBalancer service type
- K3s ServiceLB binds port 80 on host (172.20.14.68)

### vLLM Inference (charts/tgi/)
- Switched from TGI (x86-only) to vLLM via NVIDIA NGC image (nvcr.io/nvidia/vllm:26.01-py3)
- ARM64-native, purpose-built for DGX Spark
- Serving Qwen/Qwen3-8B with max_model_len=8192
- OpenAI-compatible API on port 8080 (same as TGI was)
- No NGC API key needed (image is publicly accessible)

### Ingress Chart (charts/ingress/)
- Created path-based routing chart for spark-b0f2.local
- Routes: /skill-adapter-frontend → frontend:3000, /skill-adapter-api → api:8000, /skill-adapter-inference → tgi:8080

### Documentation
- Created docs/06_kubernetes_setup.md (full setup guide)
- Updated docs/01_dgx_spark_setup.md (link to K8s doc)
- Updated repo CLAUDE.md (K8s infrastructure, vLLM migration)
- Updated practice CLAUDE.md (K8s context, SSH sudo notes)

### Docker NVIDIA Runtime
- Configured /etc/docker/daemon.json with nvidia as default runtime
- Note: This is for direct Docker use only; K3s uses its own containerd

## Key Lessons Learned
1. **Do NOT use K3s `--docker` flag** — Docker CRI doesn't support RuntimeClass, which the GPU Operator requires for its pods
2. **K3s auto-detects nvidia runtime** — no manual containerd config needed when NVIDIA Container Toolkit is installed
3. **TGI Docker image is x86-only** — use NVIDIA NGC vLLM image for ARM64 DGX Spark
4. **NGC vLLM image is publicly accessible** — no NGC API key needed
5. **GPU Operator MUST be v25.10.0+** for DGX Spark GB10 support
6. **SSH sudo over non-interactive shell**: use `echo <password> | sudo -S <command>` with bare echo (no quotes around password containing `!`)

## Current K8s State on Spark
- Node: spark-b0f2, Ready, v1.34.3+k3s1, containerd://2.1.5-k3s1
- GPU: nvidia.com/gpu: "1" allocatable
- Pods running: vLLM (tgi), GPU Operator suite, NGINX Ingress, CoreDNS, metrics-server
- Ingress: LoadBalancer on 172.20.14.68:80

## Remaining Work
- Deploy frontend and backend services to K8s (Step 8 from plan — requires building Docker images)
- Test ingress routes end-to-end from Mac
- Consider upgrading model from Qwen3-8B to larger model (125GB RAM available)
- Consider renaming charts/tgi/ to charts/inference/ or charts/vllm/ for clarity

## CLAUDE.md Updates Needed
- Added SSH sudo pattern and DGX-SPARK.md reference
- Added K8s infrastructure details (K3s, GPU Operator, containerd, NGINX Ingress)
- Added vLLM migration notes (TGI x86-only, vLLM ARM64-native)
- These updates should persist for future sessions
