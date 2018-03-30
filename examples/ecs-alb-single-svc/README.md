# Example ecs-alb-single-svc
A simple example that demonstrates how to create an ECS cluster, ALB & ECS service.

## Pre-requisites
1. Public zone in Route 53 (ex. domain_name=example.com)
2. SSL Certificate issued using Amazon Certificate Manager (ex. certificate_arn=...)

## Usage
```
$ terraform init
$ terraform plan
$ terraform apply
```
