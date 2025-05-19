# resource "aws_s3_bucket" "example" {
#   bucket = "helloagain-example-bucket-${var.env}"
#   tags = {
#     Environment = var.env
#   }
# }

# # Configuring VPC for test environment
# module "vpc" {
#   source              = "../../modules/vpc"
#   env                 = var.env
#   vpc_cidr            = "10.1.0.0/16"
#   public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
#   private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
#   availability_zones  = ["${REGION}a", "${REGION}b"]
# }

# module "eks" {
#   source             = "../../modules/eks"
#   env                = var.env
#   public_subnet_ids  = module.vpc.public_subnet_ids
#   private_subnet_ids = module.vpc.private_subnet_ids
#   node_desired_size  = 2
#   node_max_size      = 4
#   node_min_size      = 1
#   instance_type      = "t3.medium"
#   oidc_provider_arn  = aws_iam_openid_connect_provider.eks.arn
#   oidc_issuer_url    = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
# }

# resource "aws_ecr_repository" "cors_proxy" {
#   name = "${var.env}-cors-proxy"
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration {
#     scan_on_push = true
#   }
#   tags = {
#     Environment = var.env
#   }
# }

# output "ecr_repository_url" {
#   value = aws_ecr_repository.cors_proxy.repository_url
# }

# # Get the OIDC provider URL from the EKS cluster
# data "aws_eks_cluster" "cluster" {
#   name = "dev-eks-cluster"
# }

# # Create the OIDC provider
# resource "aws_iam_openid_connect_provider" "eks" {
#   url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [""] # Your thumbprint
# }