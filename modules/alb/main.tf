resource "random_pet" "this" {
  length = 2
}

resource "aws_security_group_rule" "instance_in_alb" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "tcp"
  source_security_group_id = module.alb_sg_https.this_security_group_id
  security_group_id        = var.backend_sg_id
}

module "alb_sg_https" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "alb-sg-${random_pet.this.id}"
  description = "Security group for example usage with ALB"
  vpc_id  = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  tags = var.tags
}

data "aws_route53_zone" "domain" {
  name         = "${var.domain_name}."
  private_zone = var.private_zone
}

resource "aws_route53_record" "hostname" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.host_name != "" ? format("%s.%s", var.host_name, data.aws_route53_zone.domain.name) : format("%s", data.aws_route53_zone.domain.name)
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }
}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 2.0"

  domain_name = var.domain_name # trimsuffix(data.aws_route53_zone.domain.name, ".") # Terraform >= 0.12.17
  zone_id     = data.aws_route53_zone.domain.id
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.2.0"

  name = "${var.name}-${random_pet.this.id}"
  load_balancer_type = "application"
  vpc_id  = var.vpc_id
  security_groups = [module.alb_sg_https.this_security_group_id]
  subnets = var.vpc_subnets

  target_groups = [
    {
      name_prefix      = "h1"
      backend_protocol     = var.backend_protocol
      backend_port         = var.backend_port
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.this_acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags    = var.tags
}
