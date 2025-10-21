
output "ecr_hello_app_repository_name" {
  value       = aws_ecr_repository.hello_app.name
  description = "ECR repository name"
}

output "ecr_hello_app_repository_url" {
  value       = aws_ecr_repository.hello_app.repository_url
  description = "ECR repository URL (push/pull endpoint)"
}

output "ecr_hello_app_repository_arn" {
  value       = aws_ecr_repository.hello_app.arn
  description = "ECR repository ARN"
}