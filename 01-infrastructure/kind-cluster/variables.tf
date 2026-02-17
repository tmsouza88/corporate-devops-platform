variable "cluster_name" {
  description = "Name of the Kind cluster"
  type        = string
  default     = "corporate-platform"
}

variable "worker_nodes" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}
