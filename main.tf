provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

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
    name      = "deny-all"
    namespace = kubernetes_namespace.calico.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

###############
# Deployment  #
###############
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "mydemoapp"
    labels = {
      test = "mydemoapp"
    }
    namespace = kubernetes_namespace.calico.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "mydemoapp"
      }
    }

    template {
      metadata {
        labels = {
          test = "mydemoapp"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "mydemoapp"

          port {
            container_port = 80
          }

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

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.test
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "Clusterip"
  }
}