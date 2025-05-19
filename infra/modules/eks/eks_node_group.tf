# Configuring EKS node group for scalability
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.env}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.private_subnet_ids
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }
  # Add metadata options via launch template
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }
  instance_types = [var.instance_type]
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_policy
  ]
}

resource "aws_launch_template" "eks_nodes" {
  name = "${var.env}-eks-nodes"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" 
    http_put_response_hop_limit = 2         
  }
}