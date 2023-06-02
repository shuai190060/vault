# eks cluster
resource "aws_eks_cluster" "vault" {
  name     = "vault_cluster"
  role_arn = aws_iam_role.vault.arn
  version  = "1.26"


  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    subnet_ids = [
      aws_subnet.private_subnet[0].id,
      aws_subnet.private_subnet[1].id,
      aws_subnet.public_subnet[0].id,
      aws_subnet.public_subnet[1].id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eksclusterpolicy_attach]
}

output "endpoint" {
  value = aws_eks_cluster.vault.endpoint
}

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.vault.certificate_authority[0].data
# }

output "eks_cluster_id" {
  value = aws_eks_cluster.vault.id

}


# aws eks nodes
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.vault.name
  node_group_name = "nodes-vault"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]
  disk_size      = 10

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  remote_access {
    ec2_ssh_key = "ec2-learning"
  }
  depends_on = [
    aws_iam_role_policy_attachment.nodes_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.nodes_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.nodes_amazon_ec2_container_registry_read_only,
  ]

  # # for karpenter
  # tags = {
  #   "karpenter.sh/discovery" = "${aws_eks_cluster.vault.id}"
  # }

}


# OpenID connect provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.vault.identity[0].oidc[0].issuer

}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.vault.identity[0].oidc[0].issuer
}