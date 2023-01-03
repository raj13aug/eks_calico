############
## Calico ##
############
resource "helm_release" "calico" {
  name             = "calico"
  repository       = "https://projectcalico.docs.tigera.io/charts"
  chart            = "tigera-operator"
  namespace        = "tigera-operator"
  create_namespace = true

  set {
    name  = "kubernetesProvider"
    value = "EKS"
  }
}

############
## Demo   ##
############
resource "kubernetes_namespace" "calico" {

  metadata {
    labels = {
      name = "demo"
    }

    name = "demo"
  }
}

resource "kubernetes_network_policy" "calico_default_deny" {

  metadata {
    name      = "default-deny"
    namespace = kubernetes_namespace.calico.name
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress", "Egress"]
  }
}