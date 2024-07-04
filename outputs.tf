output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.flow_log_bucket.id
}

output "flow_log_role_arn" {
  description = "The ARN of the IAM role used by the flow log"
  value       = aws_iam_role.flow_log_role.arn
}