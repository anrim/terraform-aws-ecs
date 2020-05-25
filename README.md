# AWS ECS Terraform Module

## Features
* [x] Create an ECS cluster using the [cluster](https://github.com/anrim/terraform-aws-ecs/tree/master/modules/cluster) sub-module
* [x] Create an ALB using the [alb](https://github.com/anrim/terraform-aws-ecs/tree/master/modules/alb) sub-module
* [x] Create an ECS service using the [service](https://github.com/anrim/terraform-aws-ecs/tree/master/modules/service) sub-module
* [ ] Support [awsvpc](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html) task networking mode for simple service discovery between services using Route 53
* [ ] Support [Fargate](https://aws.amazon.com/fargate/) (managed ECS cluster, run containers without having to manage an ECS cluster)

## Usage
```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.33.0"

  name               = "app-dev"
  cidr               = "10.10.10.0/24"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.10.10.0/27", "10.10.10.32/27", "10.10.10.64/27"]
  public_subnets     = ["10.10.10.96/27", "10.10.10.128/27", "10.10.10.160/27"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = {
    Environment = "dev"
    Owner = "me"
  }
}

module "ecs_cluster" {
  source = "anrim/ecs/aws//modules/cluster"

  name = "app-dev"
  vpc_id      = module.vpc.vpc_id
  vpc_subnets = [module.vpc.private_subnets]
  tags        = {
    Environment = "dev"
    Owner = "me"
  }
}

module "alb" {
  source = "anrim/ecs/aws//modules/alb"

  name            = "app-dev"
  host_name       = "app"
  domain_name     = "example.com"
  certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  backend_sg_id   = module.ecs_cluster.instance_sg_id
  tags            = {
    Environment = "dev"
    Owner = "me"
  }
  vpc_id      = module.vpc.vpc_id
  vpc_subnets = [module.vpc.public_subnets]
}

resource "aws_ecs_task_definition" "app" {
  family = "app-dev"
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
        "awslogs-group": "app-dev-nginx",
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

  name = "app-dev"
  alb_target_group_arn = module.alb.target_group_arn
  cluster              = module.ecs_cluster.cluster_id
  container_name       = "nginx"
  container_port       = "80"
  log_groups           = ["app-dev-nginx"]
  task_definition_arn  = "aws_ecs_task_definition.app.arn
  tags                 = {
    Environment = "dev"
    Owner = "me"
  }
}
```

## Examples
* [ECS cluster with a single ALB and service (Nginx)](https://github.com/anrim/terraform-aws-ecs/tree/master/examples/ecs-alb-single-svc)

## License
Apache 2 Licensed. See LICENSE for full details.
