variable "image_url" {
  description = "The URL of the Docker image to deploy."
  type        = string
}
variable "eks_cluster_endpoint" { type = string }
variable "eks_cluster_ca_cert" { type = string }
variable "eks_cluster_auth_token" { type = string }