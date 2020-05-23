output "cluster_id" {
  value = aws_ecs_cluster.ecs.id
}

output "instance_sg_id" {
  value = aws_security_group.instance.id
}

output "instance_role" {
  value = aws_iam_role.instance.name
}

