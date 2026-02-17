# Infrastructure Module

## Objetivo
Provisionar cluster Kubernetes local usando Kind via Terraform.

## Componentes
- 1 Control Plane node
- 2 Worker nodes
- NGINX Ingress Controller
- Namespaces: production, staging, development, monitoring, flux-system

## Uso

```bash
cd 01-infrastructure/kind-cluster

# Inicializar
terraform init

# Planejar
terraform plan

# Aplicar
terraform apply -auto-approve

# Verificar
kubectl get nodes
kubectl get namespaces

# Destruir
terraform destroy -auto-approve
