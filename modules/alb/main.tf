resource "aws_security_group_rule" "instance_in_alb" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "tcp"
  source_security_group_id = "${module.alb_sg_https.this_security_group_id}"
  security_group_id        = "${var.backend_sg_id}"
}

module "alb_sg_https" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "${var.name}-alb"
  vpc_id = "${var.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = "${var.tags}"
}

module "alb" {
  source              = "terraform-aws-modules/alb/aws"
  alb_is_internal     = "${var.internal}"
  alb_name            = "${var.name}"
  alb_protocols       = ["HTTPS"]
  alb_security_groups = ["${module.alb_sg_https.this_security_group_id}"]

  backend_port     = "${var.backend_port}"
  backend_protocol = "${var.backend_protocol}"

  certificate_arn = "${var.certificate_arn}"

  health_check_healthy_threshold   = "${var.health_check_healthy_threshold}"
  health_check_interval            = "${var.health_check_interval}"
  health_check_matcher             = "${var.health_check_matcher}"
  health_check_path                = "${var.health_check_path}"
  health_check_port                = "${var.health_check_port}"
  health_check_timeout             = "${var.health_check_timeout}"
  health_check_unhealthy_threshold = "${var.health_check_unhealthy_threshold}"

  create_log_bucket        = "${var.create_log_bucket}"
  enable_logging           = "${var.enable_logging}"
  force_destroy_log_bucket = "${var.force_destroy_log_bucket}"
  log_bucket_name          = "${var.log_bucket_name != "" ? var.log_bucket_name : format("%s-logs", var.name)}"
  log_location_prefix      = "alb"

  subnets = ["${var.vpc_subnets}"]
  tags    = "${var.tags}"
  vpc_id  = "${var.vpc_id}"
}

data "aws_route53_zone" "domain" {
  name         = "${var.domain_name}."
  private_zone = "${var.private_zone}"
}

resource "aws_route53_record" "hostname" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "${var.host_name != "" ? format("%s.%s", var.host_name, data.aws_route53_zone.domain.name) : format("%s", data.aws_route53_zone.domain.name)}"
  type    = "A"

  alias {
    name                   = "${module.alb.alb_dns_name}"
    zone_id                = "${module.alb.alb_zone_id}"
    evaluate_target_health = true
  }
}
