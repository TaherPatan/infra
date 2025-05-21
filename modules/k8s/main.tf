provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  token                  = var.eks_cluster_auth_token
  cluster_ca_certificate = base64decode(var.eks_cluster_ca_cert)
}

resource "kubernetes_deployment" "my_app" {
  metadata {
    name = "my-app"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "my-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }
      spec {
        container {
          image = var.image_url
          name  = "my-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "my_app_service" {
  metadata {
    name = "my-app-service"
  }
  spec {
    selector = {
      app = "my-app"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
