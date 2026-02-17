#!/usr/bin/env bash
set -euo pipefail

# checkpoint02.sh
# Valida o Módulo 02 (Governança) — ResourceQuotas e NetworkPolicies
# Uso: bash ./scripts/checkpoint02.sh

# Colors (se terminal suportar)
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

info() { printf "${GREEN}✔ %s${NC}\n" "$1"; }
warn() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; }
err()  { printf "${RED}✖ %s${NC}\n" "$1"; exit 1; }

echo ""
printf "🔍 Running Module 02 checkpoint (Governance)\n\n"

# 0) Check required commands
for cmd in kubectl ansible-playbook; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Required command '$cmd' not found in PATH. Install or activate your venv and retry."
  fi
done
info "Required commands found"

# 1) Check current kube context (expect kind-corporate-platform)
CURRENT_CTX=$(kubectl config current-context 2>/dev/null || echo "")
if [[ -z "$CURRENT_CTX" ]]; then
  warn "No current kube context. Make sure kubeconfig is set."
else
  info "Current kubectl context: $CURRENT_CTX"
fi

# 2) Namespaces that should exist for Module 02
namespaces=(development staging production)
for ns in "${namespaces[@]}"; do
  if kubectl get namespace "$ns" >/dev/null 2>&1; then
    info "Namespace '$ns' exists"
  else
    err "Namespace '$ns' NOT found (create or re-run Module 01)"
  fi
done

# 3) ResourceQuota existence & quick sanity check
echo ""
echo "🔎 Validating ResourceQuotas..."
all_rq_ok=true
for ns in "${namespaces[@]}"; do
  rq_name="${ns}-quota"
  if kubectl get resourcequota -n "$ns" "$rq_name" >/dev/null 2>&1; then
    info "ResourceQuota '$rq_name' found in namespace '$ns'"
    echo "-> summary for $ns:"
    kubectl describe resourcequota -n "$ns" "$rq_name" | sed -n '1,12p'
  else
    warn "ResourceQuota '$rq_name' NOT found in namespace '$ns'"
    all_rq_ok=false
  fi
done

if [ "$all_rq_ok" = false ]; then
  warn "One or more ResourceQuotas are missing. If you haven't run the Ansible playbook, execute:"
  echo "  ansible-playbook -i inventory.ini playbook.yml"
  echo ""
else
  info "All expected ResourceQuotas present"
fi

# 4) NetworkPolicy existence & quick check
echo ""
echo "🔎 Validating NetworkPolicies..."
all_np_ok=true
np_name="default-deny-ingress"
for ns in "${namespaces[@]}"; do
  if kubectl get networkpolicy -n "$ns" "$np_name" >/dev/null 2>&1; then
    info "NetworkPolicy '$np_name' found in namespace '$ns'"
    echo "-> summary for $ns:"
    kubectl describe networkpolicy -n "$ns" "$np_name" | sed -n '1,12p'
  else
    warn "NetworkPolicy '$np_name' NOT found in namespace '$ns'"
    all_np_ok=false
  fi
done

if [ "$all_np_ok" = false ]; then
  warn "One or more NetworkPolicies are missing. Re-run the Ansible role or inspect templates/roles."
else
  info "All expected NetworkPolicies present"
fi

# 5) Sanity: check that pods can still run at least one demo pod per namespace (optional)
echo ""
echo "🔎 Optional: quick test deploy (ephemeral) to check quotas enforcement"

test_pod_manifest=$(mktemp)
cat > "$test_pod_manifest" <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: governance-test
spec:
  containers:
  - name: pause
    image: k8s.gcr.io/pause:3.8
    resources:
      requests:
        cpu: "10m"
        memory: "16Mi"
YAML

for ns in "${namespaces[@]}"; do
  # delete any previous test pod
  kubectl delete pod governance-test -n "$ns" --ignore-not-found=true >/dev/null 2>&1 || true
  if kubectl apply -f "$test_pod_manifest" -n "$ns" >/dev/null 2>&1; then
    # wait a short time for pod to schedule
    if kubectl wait --for=condition=ready pod/governance-test -n "$ns" --timeout=10s >/dev/null 2>&1; then
      info "Test pod started OK in namespace '$ns' (within quota)"
    else
      warn "Test pod did not reach Ready quickly in '$ns' (might be fine if image pull or scheduling delayed)"
    fi
    kubectl delete pod governance-test -n "$ns" --wait --timeout=20s >/dev/null 2>&1 || true
  else
    warn "Failed to create test pod in '$ns' — may indicate strict quotas or other issues"
  fi
done
rm -f "$test_pod_manifest"

echo ""
# Final decision
if [ "$all_rq_ok" = true ] && [ "$all_np_ok" = true ]; then
  info "Module 02 checkpoint PASSED"
  exit 0
else
  warn "Module 02 checkpoint NOT fully passed (see messages above)"
  exit 2
fi