provider "aws" {
  version = "~> 4.0"
  region  = var.region
}

resource "aws_s3_bucket" "flow_log_bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_iam_role" "flow_log_role" {
  name = "${var.bucket_name}_flow_log_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.bucket_name}_flow_log_policy"
  role = aws_iam_role.flow_log_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.flow_log_bucket.arn,
          "${aws_s3_bucket.flow_log_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_flow_log" "flow_log" {
  log_destination      = aws_s3_bucket.flow_log_bucket.arn
  log_destination_type = "s3"
  traffic_type         = var.traffic_type
  vpc_id               = var.vpc_id
  iam_role_arn         = aws_iam_role.flow_log_role.arn
}
