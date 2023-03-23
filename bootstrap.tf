# Define the AWS provider and region
provider "aws" {
  region = "us-east-1"
}

# Define an S3 bucket resource for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  # Specify the bucket name
  bucket = "my-terraform-state-bucket"

  # Enable versioning for the bucket
  versioning {
    enabled = true
  }

  # Enable server-side encryption for the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Set ACLs to prevent public access to the bucket
  # These attributes are used instead of 'acl = "private"', which is outdated
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true

  # Define a bucket policy that allows access to the bucket for Terraform
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}",
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      }
    ]
  })

  # Define tags for the bucket to identify it as being used for Terraform state
  tags = {
    Environment = "Terraform"
  }
}

# Output the name of the S3 bucket for Terraform state
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}
