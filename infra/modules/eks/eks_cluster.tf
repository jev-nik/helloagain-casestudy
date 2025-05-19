# Setting up EKS cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.env}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids         = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access = true
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
      ]
}