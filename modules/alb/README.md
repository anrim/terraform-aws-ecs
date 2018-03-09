# AWS ALB Terraform Module
This module creates an ALB and DNS record for the provided hostname in Route 53.

## Features
* [x] Create ALB with default target group
* [x] Create DNS A record for sub-domain or root domain

## Usage
```
module "alb" {
  source = "anrim/ecs/aws//modules/alb"

  name            = "app-dev"
  host_name       = "app"
  domain_name     = "example.com"
  certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  backend_sg_id   = "${module.ecs_cluster.instance_sg_id}"
  tags            = {
    Environment = "dev"
    Owner = "me"
  }
  vpc_id      = "${module.vpc.vpc_id}"
  vpc_subnets = ["${module.vpc.public_subnets}"]
}
```

## License
Apache 2 Licensed. See LICENSE for full details.
