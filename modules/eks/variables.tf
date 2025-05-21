variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
variable "subnet_ids" { type = list(string) }
