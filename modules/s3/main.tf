resource "aws_s3_bucket" "flytrap_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.flytrap_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowLambdaAccess",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action    = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.flytrap_bucket.arn}",
          "${aws_s3_bucket.flytrap_bucket.arn}/*"
        ]
        Condition =  {
          StringEquals = {
           "AWS:SourceArn" = var.lambda_iam_role_arn
           }
        }
      },
      {
        Sid       = "AllowCLIUpload",
        Effect    = "Allow",
        Principal: {
          AWS: var.current_user_arn
        },
        Action    = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "${aws_s3_bucket.flytrap_bucket.arn}/*"
      }
    ]
  })
}
