
# Create IAM Users
resource "aws_iam_user" "admin" {
  name = "datazone-admin"
}

resource "aws_iam_user" "producer" {
  name = "datazone-producer"
}

resource "aws_iam_user" "consumer" {
  name = "datazone-consumer"
}

# Enable Console Login for Users
resource "aws_iam_user_login_profile" "admin_console" {
  user = aws_iam_user.admin.name
  #   password = var.admin_password
  password_reset_required = true
}

resource "aws_iam_user_login_profile" "producer_console" {
  user = aws_iam_user.producer.name
  #   password = var.producer_password
  password_reset_required = true
}

resource "aws_iam_user_login_profile" "consumer_console" {
  user = aws_iam_user.consumer.name
  #   password = var.consumer_password
  password_reset_required = true
}

# Create Access Keys for Programmatic Access
resource "aws_iam_access_key" "admin" {
  user = aws_iam_user.admin.name
}

resource "aws_iam_access_key" "producer" {
  user = aws_iam_user.producer.name
}

resource "aws_iam_access_key" "consumer" {
  user = aws_iam_user.consumer.name
}

# Admin Policy - Full Access for DataZone Admin
resource "aws_iam_policy" "datazone_admin_policy" {
  name        = "DataZoneAdminPolicy"
  description = "Policy granting DataZone Admin permissions"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "datazone:*",      # Full DataZone access
          "iam:*",           # IAM access
          "secretsmanager:*" # Secrets Manager access
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "admin_policy_attachment" {
  user       = aws_iam_user.admin.name
  policy_arn = aws_iam_policy.datazone_admin_policy.arn
}

# Attach Redshift Full Access to Users
resource "aws_iam_user_policy_attachment" "admin_redshift_full_access" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

# Attach Amazon DataZone Full Access to Admin User
resource "aws_iam_user_policy_attachment" "admin_datazone_full_access" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneFullAccess"
}

# Attach Amazon DataZone Full Access to Admin User
resource "aws_iam_user_policy_attachment" "admin_rsdata_full_access" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftDataFullAccess"
}

# Attach Amazon DataZone Full Access to Admin User
resource "aws_iam_user_policy_attachment" "admin_rsqev2_full_access" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftQueryEditorV2FullAccess"
}

# Producer Policy - Create and List DataZone Resources
resource "aws_iam_policy" "datazone_producer_policy" {
  name        = "DataZoneProducerPolicy"
  description = "Policy granting Producer permissions"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "datazone:Create*", # Allow creating resources
          "datazone:List*"    # Allow listing resources
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "producer_policy_attachment" {
  user       = aws_iam_user.producer.name
  policy_arn = aws_iam_policy.datazone_producer_policy.arn
}

# Consumer Policy - Read-only Access
resource "aws_iam_policy" "datazone_consumer_policy" {
  name        = "DataZoneConsumerPolicy"
  description = "Policy granting Consumer permissions"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "datazone:Get*", # Allow reading resources
          "datazone:List*" # Allow listing resources
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "consumer_policy_attachment" {
  user       = aws_iam_user.consumer.name
  policy_arn = aws_iam_policy.datazone_consumer_policy.arn
}


