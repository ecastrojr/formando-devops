resource "kind_cluster" "default" {
  name = var.cluster_name
  wait_for_ready = true
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-panel"
      image = "kindest/node:${var.kubernetes_version}"
    }

    node {
      role = "worker"
      kubeadm_config_patches = [
        "kind: JoinConfiguration\nnodeRegistration:\n  taints:\n    - key: \"dedicated\"\n      value: \"infra\"\n      effect: \"NoSchedule\"\n  kubeletExtraArgs:\n    node-labels: \"role=infra\"\n"
      ]
      image = "kindest/node:${var.kubernetes_version}"
    }

    node {
      role = "worker"
      kubeadm_config_patches = [
        "kind: JoinConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"role=app\"\n"
      ]
      image = "kindest/node:${var.kubernetes_version}"
    }
  }
}