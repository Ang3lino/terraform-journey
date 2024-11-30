# Role: Manage Role for DataZone
resource "aws_iam_role" "datazone_manage_role" {
  name = "datazone-manage-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "RedshiftTrustPolicyStatement",
        Effect = "Allow",
        Principal = {
          Service = "datazone.amazonaws.com"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.aws_account_id
          },
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:datazone:${var.region}:${var.aws_account_id}:domain/${awscc_datazone_domain.example.id}"
          }
        }
      }
    ]
  })
}

# Custom Policy for Secrets Manager
resource "aws_iam_policy" "datazone_manage_secrets_policy" {
  name        = "DataZoneManageSecretsPolicy"
  description = "Policy for managing Redshift secrets in DataZone"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "RedshiftSecretStatement",
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = "*",
        Condition = {
          StringEquals = {
            "secretsmanager:ResourceTag/AmazonDataZoneDomain" = awscc_datazone_domain.example.id
          }
        }
      }
    ]
  })
}

# Attach Custom Policy to Manage Role
resource "aws_iam_role_policy_attachment" "datazone_manage_custom_policy_attachment" {
  role       = aws_iam_role.datazone_manage_role.name
  policy_arn = aws_iam_policy.datazone_manage_secrets_policy.arn
}

# Attach Managed Policy for Redshift
resource "aws_iam_role_policy_attachment" "datazone_manage_managed_policy_attachment" {
  role       = aws_iam_role.datazone_manage_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneRedshiftManageAccessRolePolicy"
}
