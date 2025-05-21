# Infrastructure Provisioning with Terraform

This directory contains Terraform configurations to provision the necessary AWS infrastructure for deploying the Document Management and Q&A application.

## Overview

This Terraform setup automates the creation of:

*   An **Amazon EKS (Elastic Kubernetes Service)** cluster to host the application containers.
*   An **Amazon RDS (Relational Database Service)** PostgreSQL instance for the backend database.
*   **Amazon ECR (Elastic Container Registry)** repositories for storing frontend and backend Docker images.
*   **Kubernetes resources** (Deployments, Services, ConfigMaps, Secrets) within the EKS cluster to run the frontend and backend applications.

## Architecture

The provisioned infrastructure consists of:

1.  **EKS Cluster:** A managed Kubernetes cluster providing the compute and orchestration layer.
2.  **Node Group:** EC2 instances that serve as worker nodes for the EKS cluster.
3.  **RDS PostgreSQL Instance:** A managed PostgreSQL database for persistent data storage for the backend.
4.  **ECR Repositories:** Private Docker image registries for the `frontend-app` and `backend-app`.
5.  **Kubernetes Deployments:**
    *   **Backend:** FastAPI application connected to the RDS database, configured with necessary secrets and environment variables.
    *   **Frontend:** Angular application served by Nginx, with Nginx configured to serve static files and proxy API requests to the backend.
6.  **Kubernetes Services:**
    *   `LoadBalancer` services are created for both frontend and backend, exposing them externally (this can be refined with an Ingress controller).
7.  **Kubernetes Configuration:**
    *   `Secrets` for database credentials and application secrets (e.g., JWT secret key).
    *   `ConfigMaps` for application configurations (e.g., Nginx config, backend non-sensitive settings).

## Prerequisites

Before applying this Terraform configuration, ensure you have:

1.  **Terraform CLI:** Installed on your local machine (preferably the latest version).
2.  **AWS CLI:** Installed and configured with an AWS account and appropriate IAM permissions to create the resources defined (EKS, RDS, EC2, VPC resources, IAM roles, ECR, etc.).
3.  **Docker Images (Pre-built & Pushed - Recommended):**
    *   The frontend and backend Docker images should be built and pushed to the ECR repositories that this Terraform configuration will create (or to your specified ECR image URLs).
    *   The default ECR repository names are derived from the `cluster_name` variable (e.g., `my-doc-app-cluster-frontend-app`).
    *   Alternatively, you can provide full image URLs via the `frontend_image_url` and `backend_image_url` variables.

## Directory Structure

*   `main.tf`: The root Terraform configuration file defining providers, data sources, variables, locals, and module instantiations.
*   `variables.tf` (implicitly, variables are defined in `main.tf`): Defines input variables for the root module.
*   `modules/`: Contains reusable Terraform modules.
    *   `modules/eks/`: Module for provisioning the EKS cluster and node group.
    *   `modules/k8s/`: Generic module for deploying Kubernetes applications (Deployments, Services).

## Configuration (Input Variables)

You **must** configure the following variables in `infra/main.tf` or by providing a `.tfvars` file:

*   `vpc_id`: (String) The ID of the VPC where the EKS cluster and RDS instance will be deployed.
*   `cluster_subnet_ids`: (List of Strings) A list of subnet IDs within your specified VPC. These subnets will be used for the EKS cluster control plane, worker nodes, and the RDS instance. Ensure these subnets have appropriate routing and internet access if needed (e.g., via a NAT Gateway for private subnets).
*   `backend_secret_key`: (String, Sensitive) A strong, unique secret key (minimum 32 characters) for JWT token generation in the backend.

Other important variables you might want to configure:

*   `cluster_name`: (String) Name for the EKS cluster and used as a prefix for many resources. Default: `my-doc-app-cluster`.
*   `region`: (String) AWS region for deployment. Default: `ap-south-1` (defined in the AWS provider block).
*   `frontend_image_url`: (String) Full ECR image URL for the frontend application. If left empty, a default is constructed using your AWS account ID, region, and the ECR repository name created by Terraform.
*   `backend_image_url`: (String) Full ECR image URL for the backend application. If left empty, a default is constructed similarly.
*   `db_password`: (String, Sensitive) Password for the RDS database master user. Default: `MustBeChanged123!`. **It is highly recommended to change this.**
*   `db_name`, `db_username`, `db_instance_class`: RDS database configuration.
*   `backend_jwt_algorithm`, `backend_cors_origins`: Backend application settings.

Review `infra/main.tf` for all available variables and their default values.

## Usage / Deployment Steps

1.  **Navigate to the `infra` directory:**
    ```bash
    cd infra
    ```

2.  **Initialize Terraform:**
    This command downloads the necessary providers and modules.
    ```bash
    terraform init
    ```

3.  **Review the Execution Plan:**
    This command shows you what resources Terraform will create, modify, or destroy.
    ```bash
    terraform plan
    ```
    Carefully review the output before proceeding.

4.  **Apply the Configuration:**
    This command provisions the infrastructure on AWS. You will be prompted to confirm.
    ```bash
    terraform apply
    ```
    Type `yes` to proceed. This process can take several minutes, especially for EKS cluster and RDS instance creation.

5.  **Accessing the Application:**
    Once `terraform apply` is complete, the Kubernetes services for frontend and backend (if `service_type = "LoadBalancer"`) will provision AWS Load Balancers. You can get their external DNS names from the AWS console or using `kubectl get svc -n <namespace>`.

6.  **Destroying the Infrastructure:**
    To remove all resources created by this Terraform configuration:
    ```bash
    terraform destroy
    ```
    Type `yes` to confirm. This will de-provision EKS, RDS, ECR repositories, and other associated resources.

## Important Notes & Future Refinements

Please review the `TODO` comments at the end of `infra/main.tf` for important considerations and potential future enhancements, including:

*   **Ingress Controller:** Implementing an Ingress controller (e.g., AWS LoadBalancer Controller) for better traffic management and cost optimization.
*   **Secrets Management:** Using AWS Secrets Manager for sensitive data like `db_password` and `backend_secret_key`.
*   **Security:** Refining security group rules and IAM policies for least privilege.
*   **Kubernetes Namespaces:** Using dedicated namespaces for better resource organization.
*   **Probes:** Adding liveness and readiness probes to Kubernetes deployments.
*   **Frontend API URL:** If the frontend needs to be explicitly configured with the backend API URL (beyond Nginx proxying), a mechanism for this should be implemented.