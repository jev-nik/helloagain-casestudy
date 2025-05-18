resource "aws_s3_bucket" "example" {
    bucket = "helloagain-example-bucket-${var.env}"
    tags = {
      Environment = var.env
    }
  }

# Configuring VPC for test environment
module "vpc" {
  source              = "../../modules/vpc"
  env                 = var.env
  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones  = ["eu-central-1a", "eu-central-1b"]
}

# # Deploying EKS cluster
# module "eks" {
#   source             = "../../modules/eks"
#   env                = "dev"
#   public_subnet_ids  = module.vpc.public_subnet_ids
#   private_subnet_ids = module.vpc.private_subnet_ids
#   node_desired_size  = 2
#   node_max_size      = 4
#   node_min_size      = 1
#   instance_type      = "t3.medium"
# }

resource "aws_ecr_repository" "cors_proxy" {
  name = "${var.env}-cors-proxy"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment = var.env
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.cors_proxy.repository_url
}