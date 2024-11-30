
# Role: Provisioning Role for DataZone
resource "aws_iam_role" "datazone_provisioning_role" {
  name = "datazone-provisioning-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "datazone.amazonaws.com"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.aws_account_id
          }
        }
      }
    ]
  })
}

# Attach Managed Policy: AmazonDataZoneRedshiftGlueProvisioningPolicy
resource "aws_iam_role_policy_attachment" "provisioning_managed_policy_attachment" {
  role       = aws_iam_role.datazone_provisioning_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneRedshiftGlueProvisioningPolicy"
}
