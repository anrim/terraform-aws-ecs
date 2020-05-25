provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 1.26.0"

  name               = "ecs-alb-single-svc"
  cidr               = "10.10.10.0/24"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.10.10.0/27", "10.10.10.32/27", "10.10.10.64/27"]
  public_subnets     = ["10.10.10.96/27", "10.10.10.128/27", "10.10.10.160/27"]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Owner       = "user"
    Environment = "me"
  }
}

module "ecs_cluster" {
  source = "anrim/ecs/aws//modules/cluster"

  name        = "ecs-alb-single-svc"
  vpc_id      = module.vpc.vpc_id
  vpc_subnets = [module.vpc.private_subnets]

  tags = {
    Owner       = "user"
    Environment = "me"
  }
}

module "alb" {
  source = "anrim/ecs/aws//modules/alb"

  name                     = "ecs-alb-single-svc"
  host_name                = "app"
  domain_name              = "example.com"
  certificate_arn          = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  backend_sg_id            = module.ecs_cluster.instance_sg_id
  create_log_bucket        = true
  enable_logging           = true
  force_destroy_log_bucket = true
  log_bucket_name          = "ecs-alb-single-svc-logs"

  tags = {
    Owner       = "user"
    Environment = "me"
  }

  vpc_id      = module.vpc.vpc_id
  vpc_subnets = [module.vpc.public_subnets]
}

resource "aws_ecs_task_definition" "app" {
  family = "ecs-alb-single-svc"

  container_definitions = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:1.13-alpine",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "ecs-alb-single-svc-nginx",
        "awslogs-region": "us-east-1"
      }
    },
    "memory": 128,
    "cpu": 100
  }
]
EOF

}

module "ecs_service_app" {
  source = "anrim/ecs/aws//modules/service"

  name                 = "ecs-alb-single-svc"
  alb_target_group_arn = module.alb.target_group_arn
  cluster              = module.ecs_cluster.cluster_id
  container_name       = "nginx"
  container_port       = "80"
  log_groups           = ["ecs-alb-single-svc-nginx"]
  task_definition_arn  = aws_ecs_task_definition.app.arn

  tags = {
    Owner       = "user"
    Environment = "me"
  }
}

