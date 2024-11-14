
# Step 1: Create IAM Role for Redshift
resource "aws_iam_role" "redshift_admin_role" {
  name = "RedshiftAdminRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Step 2: Attach AmazonRedshiftFullAccess Policy to the Role
resource "aws_iam_role_policy_attachment" "redshift_admin_policy_attachment" {
  role       = aws_iam_role.redshift_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

# Step 3: Attach AmazonS3FullAccess Policy for S3 Admin Privileges
resource "aws_iam_role_policy_attachment" "s3_full_access_policy_attachment" {
  role       = aws_iam_role.redshift_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}