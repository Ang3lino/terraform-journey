
# # Create IAM Role for Provisioning
# resource "aws_iam_role" "provisioning_role" {
#   name = "DataZoneProvisioningRole"
#   assume_role_policy = jsonencode({
#     Version : "2012-10-17",
#     Statement : [
#       {
#         Effect : "Allow",
#         Principal : {
#           Service : "datazone.amazonaws.com"
#         },
#         Action : "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach Full Access Policies to Provisioning Role
# resource "aws_iam_role_policy_attachment" "provisioning_redshift_access" {
#   role       = aws_iam_role.provisioning_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "provisioning_datazone_access" {
#   role       = aws_iam_role.provisioning_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "provisioning_secretsmanager_access" {
#   role       = aws_iam_role.provisioning_role.name
#   policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
# }

# # Create IAM Role for Manage Access
# resource "aws_iam_role" "manage_access_role" {
#   name = "DataZoneManageAccessRole"
#   assume_role_policy = jsonencode({
#     Version : "2012-10-17",
#     Statement : [
#       {
#         Effect : "Allow",
#         Principal : {
#           Service : "datazone.amazonaws.com"
#         },
#         Action : "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach Full Access Policies to Manage Access Role
# resource "aws_iam_role_policy_attachment" "manage_access_redshift_access" {
#   role       = aws_iam_role.manage_access_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "manage_access_datazone_access" {
#   role       = aws_iam_role.manage_access_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "manage_access_secretsmanager_access" {
#   role       = aws_iam_role.manage_access_role.name
#   policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
# }

# DataZone Environment Blueprint Configuration
resource "aws_datazone_environment_blueprint_configuration" "example" {
  domain_id                = awscc_datazone_domain.example.id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.default_dwh.id
  enabled_regions          = ["us-east-1"]
  manage_access_role_arn   = aws_iam_role.datazone_manage_role.arn
  provisioning_role_arn    = aws_iam_role.datazone_provisioning_role.arn
}
