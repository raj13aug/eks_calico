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

#####################
## Network_policy   ##
#####################
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

###############
# Deployment  #
###############
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "MyDemoApp"
    labels = {
      test = "MyDemoApp"
    }
    namespace = kubernetes_namespace.calico.name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "MyDemoApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyDemoApp"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "MyDemoApp"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}