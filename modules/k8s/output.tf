output "service_url" {
  description = "The hostname of the load balancer for the Kubernetes service."
  value       = kubernetes_service.my_app_service.status.0.load_balancer.0.ingress.0.hostname
}
