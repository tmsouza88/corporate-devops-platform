output "cluster_name" {
  description = "Name of the Kind cluster"
  value       = kind_cluster.corporate.name
}

output "cluster_endpoint" {
  description = "Endpoint for the Kind cluster"
  value       = kind_cluster.corporate.endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = kind_cluster.corporate.kubeconfig
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate"
  value       = kind_cluster.corporate.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key"
  value       = kind_cluster.corporate.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = kind_cluster.corporate.cluster_ca_certificate
  sensitive   = true
}
