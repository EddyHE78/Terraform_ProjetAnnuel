output "aws_role_arn" {
  description = "À mettre dans la variable GitHub AWS_ROLE_ARN."
  value       = aws_iam_role.github_actions.arn
}

output "aws_region" {
  description = "À mettre dans la variable GitHub AWS_REGION."
  value       = var.aws_region
}
