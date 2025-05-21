variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
variable "subnet_ids" {
  description = "A list of subnet IDs to launch the EKS cluster in."
  type        = list(string)
}
