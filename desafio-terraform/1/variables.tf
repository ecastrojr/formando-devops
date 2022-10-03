variable "cluster_name" {
  type        = string
  description = "O nome do Cluster"
  default     = "desafio"
}

variable "kubernetes_version" {
  type        = string
  description = "A Versão do Kubernets"
  default     = "v1.23.4"
}