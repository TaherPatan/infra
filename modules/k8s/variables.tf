variable "image_url" {
  description = "The URL of the Docker image to deploy."
  type        = string
}
variable "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  type        = string
}
variable "eks_cluster_ca_cert" {
  description = "The CA certificate of the EKS cluster."
  type        = string
}
variable "eks_cluster_auth_token" {
  description = "The auth token of the EKS cluster."
  type        = string
  sensitive   = true
}