resource "aws_iam_role" "ec2_role" {
  name               = "EC2RoleForRDSAccess"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_permissions_policy" {
  name        = "EC2PermissionsPolicy"
  description = "Policy to allow EC2 instance to access RDS and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "rds:DescribeDBInstances",
          "rds:Connect",
          "rds:ExecuteStatement",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_rds_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_permissions_policy.arn