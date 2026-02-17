#!/bin/bash

echo "🔍 Checking Module 01: Infrastructure"
echo ""

# Verificar cluster
if kind get clusters 2>/dev/null | grep -q "corporate-platform"; then
    echo "✅ Kind cluster exists"
else
    echo "❌ Kind cluster not found"
    exit 1
fi

# Verificar nodes
node_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
if [ "$node_count" -eq 2 ]; then
    echo "✅ All 2 nodes are ready"
else
    echo "❌ Expected 2 nodes, found $node_count"
    exit 1
fi

# Verificar namespaces
namespaces=("production" "staging" "development" "monitoring")
for ns in "${namespaces[@]}"; do
    if kubectl get namespace "$ns" &> /dev/null; then
        echo "✅ Namespace $ns exists"
    else
        echo "❌ Namespace $ns not found"
        exit 1
    fi
done

# Verificar Ingress Controller (opcional - não bloqueia o módulo 1)
echo ""
echo "🔍 Checking optional components..."
if kubectl get namespace ingress-nginx &> /dev/null; then
    if kubectl get pods -n ingress-nginx 2>/dev/null | grep -q "Running"; then
        echo "✅ Ingress Controller is running"
    else
        echo "⚠️  Ingress Controller namespace exists but pods not running (optional for Module 01)"
    fi
else
    echo "⚠️  Ingress Controller not installed (will be installed in Module 03)"
fi

echo ""
echo "🎉 Module 01 completed successfully!"