variable "backend_port" {
  description = "The port the service on the EC2 instances listen on."
  default     = 80
}

variable "backend_protocol" {
  description = "The protocol the backend service speaks. Options: HTTP, HTTPS, TCP, SSL (secure tcp)."
  default     = "HTTP"
}

variable "backend_sg_id" {
  description = "Security group ID of the instance to add rule to allow incoming tcp from ALB"
}

variable "certificate_arn" {
  description = "ARN for SSL/TLS certificate"
  default     = "cert_arn"
}

variable "create_log_bucket" {
  description = "Create a log bucket to store ALB access logs (default=false)"
  default     = false
}

variable "domain_name" {
  description = "Domain name of a private Route 53 zone to create DNS record in"
}

variable "enable_logging" {
  description = "Enable ALB access logs (default=false)"
  default     = false
}

variable "force_destroy_log_bucket" {
  description = "Force detroy bucket if not empty (default=false)"
  default     = false
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive positive health checks before a backend instance is considered healthy."
  default     = 3
}

variable "health_check_interval" {
  description = "Interval in seconds on which the health check against backend hosts is tried."
  default     = 10
}

variable "health_check_path" {
  description = "The URL the ELB should use for health checks. e.g. /health"
  default     = "/"
}

variable "health_check_port" {
  description = "The port used by the health check if different from the traffic-port."
  default     = "traffic-port"
}

variable "health_check_timeout" {
  description = "Seconds to leave a health check waiting before terminating it and calling the check unhealthy."
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive positive health checks before a backend instance is considered unhealthy."
  default     = 3
}

variable "health_check_matcher" {
  description = "The HTTP codes that are a success when checking TG health."
  default     = "200-299"
}

variable "host_name" {
  description = "Optional hostname that will be used to created a sub-domain in Route 53. If left blank then a record will be created for the root domain (ex. example.com)"
  default     = ""
}

variable "internal" {
  description = "Use an internal load-balancer (default=false)"
  default     = false
}

variable "private_zone" {
  description = "Private Route 53 zone (default=false)"
  default     = false
}

variable "log_bucket_name" {
  description = "Name of the log bucket to create"
  default     = ""
}

variable "log_location_prefix" {
  description = "Prefix location to write logs for the ALB"
  default     = ""
}

variable "name" {
  description = "Base name to use for resources in the module"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID to create cluster in"
}

variable "vpc_subnets" {
  description = "List of subnets to put instances in"
  default     = []
}

