# AWS ECS Service Terraform Module
This module creates an ECS service taking a task definition as input and attaches it to an ALB target group.

## Features
* [x] Creates ECS service from task def
* [x] Attach service to ALB
* [ ] IAM Task role
* [ ] Network configuration (awsvpc)

## Usage
```
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

  alb_target_group_arn = "${module.alb.target_group_arn}"
  cluster              = "${module.ecs_cluster.cluster_id}"
  container_name       = "nginx"
  container_port       = "80"
  log_groups           = ["app-dev-nginx"]
  task_definition_arn  = "${aws_ecs_task_definition.app.arn}"

  tags = {
    Environment = "dev"
    Owner = "me"
  }
}
```

## License
Apache 2 Licensed. See LICENSE for full details.
