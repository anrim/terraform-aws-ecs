# AWS ECS Cluster Terraform Module
Creates an auto-scaling ECS cluster using the latest ECS-optimized AMI.

## Features
* [x] Create ECS cluster
* [x] Set Root block device size (default=50G)
* [x] Stream instance logs to CloudWatch Logs (default log group name is var.name)
* [x] Reclaim unused disk space for Docker
* [x] Add additional user data
* [x] Optional key pair. A new key pair with name=${var.name} using the public key '~/.ssh/id_rsa.pub' is created by default.
* [ ] Auto-scaling tasks (CloudWatch metrics + app auto-scaling)
* [ ] Service Discovery using Route 53 (awsvpc networking)

## Usage
```
module "ecs_cluster" {
  source = "anrim/ecs/aws//modules/cluster"

  name = "app-dev"

  tags = {
    Environment = "dev"
    Owner = "me"
  }

  vpc_azs     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_id      = "${module.vpc.vpc_id}"
  vpc_subnets = ["${module.vpc.private_subnets}"]
}
```

## License
Apache 2 Licensed. See LICENSE for full details.
