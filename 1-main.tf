terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.vault.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.vault.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.vault.id]
    command     = "aws"
  }
  #load_config_file       = false
}

# Helm provider
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.vault.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.vault.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.vault.id]
      command     = "aws"
    }
  }

}