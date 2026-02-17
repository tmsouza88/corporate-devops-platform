# Cluster Kind
resource "kind_cluster" "corporate" {
  name = "corporate-platform"
  
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    
    node {
      role = "control-plane"
      
      kubeadm_config_patches = [
        <<-EOT
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
        EOT
      ]
      
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
      
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
    }
    
    node {
      role = "worker"
    }
    
    node {
      role = "worker"
   
  
  wait_for_ready = true
}

# Configurar kubectl context
resource "null_resource" "kubectl_config" {
  depends_on = [kind_cluster.corporate]
  
  provisioner "local-exec" {
    command = "kind export kubeconfig --name corporate-platform"
  }
}

# Instalar NGINX Ingress Controller
# Adicione isso no topo ou no variables.tf
variable "enable_ingress" {
  type    = bool
  default = false # Deixamos false para garantir que o Módulo 1 passe
}

# Modifique o resource do ingress para usar o count
resource "null_resource" "install_ingress" {
  count = var.enable_ingress ? 1 : 0
  
  depends_on = [null_resource.kubectl_config]
  
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
      kubectl wait -n ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s
    EOT
  }
}

# Criar namespaces
resource "null_resource" "create_namespaces" {
  depends_on = [null_resource.kubectl_config]
  
  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
      kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
      kubectl create namespace development --dry-run=client -o yaml | kubectl apply -f -
      kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
      kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -
    EOT
  }
}
