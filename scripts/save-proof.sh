# Reset total
kubectl delete namespace ingress-nginx --ignore-not-found=true
kubectl wait --for=delete namespace/ingress-nginx --timeout=180s || true

# Remove webhook antigo se tiver sobrado (às vezes atrapalha)
kubectl delete validatingwebhookconfiguration ingress-nginx-admission --ignore-not-found=true

# Reinstala
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Aguarda os pods dos jobs aparecerem (loop curto)
for i in {1..60}; do
  POD_CREATE=$(kubectl get pods -n ingress-nginx -l job-name=ingress-nginx-admission-create -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
  POD_PATCH=$(kubectl get pods -n ingress-nginx -l job-name=ingress-nginx-admission-patch -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
  if [ -n "$POD_CREATE" ] || [ -n "$POD_PATCH" ]; then
    echo "Found pods: create=$POD_CREATE patch=$POD_PATCH"
    break
  fi
  sleep 1
done

# Captura logs (mesmo que falhe rápido)
if [ -n "$POD_CREATE" ]; then
  echo "=== LOGS admission-create ($POD_CREATE) ==="
  kubectl logs -n ingress-nginx "$POD_CREATE" --tail=200 || true
  echo "=== PREVIOUS LOGS admission-create ($POD_CREATE) ==="
  kubectl logs -n ingress-nginx "$POD_CREATE" --previous --tail=200 || true
  echo "=== DESCRIBE admission-create ($POD_CREATE) Events ==="
  kubectl describe pod -n ingress-nginx "$POD_CREATE" | sed -n '/Events:/,$p' || true
fi

if [ -n "$POD_PATCH" ]; then
  echo "=== LOGS admission-patch ($POD_PATCH) ==="
  kubectl logs -n ingress-nginx "$POD_PATCH" --tail=200 || true
  echo "=== PREVIOUS LOGS admission-patch ($POD_PATCH) ==="
  kubectl logs -n ingress-nginx "$POD_PATCH" --previous --tail=200 || true
  echo "=== DESCRIBE admission-patch ($POD_PATCH) Events ==="
  kubectl describe pod -n ingress-nginx "$POD_PATCH" | sed -n '/Events:/,$p' || true
fi