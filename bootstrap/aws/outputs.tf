output "aws_role_arn" {
  description = "À mettre dans la variable GitHub AWS_ROLE_ARN."
  value       = aws_iam_role.github_actions.arn
}

output "tf_state_bucket" {
  description = "À mettre dans la variable GitHub TF_STATE_BUCKET."
  value       = aws_s3_bucket.tfstate.bucket
}

output "aws_region" {
  description = "À mettre dans la variable GitHub AWS_REGION."
  value       = var.aws_region
}
