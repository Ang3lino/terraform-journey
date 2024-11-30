

# Create a Log Group
resource "awscc_logs_log_group" "example" {
  log_group_name = "example"
}

# resource "aws_datazone_environment_blueprint_configuration" "example" {
#   domain_id                = awscc_datazone_domain.example.id
#   environment_blueprint_id = data.aws_datazone_environment_blueprint.default_dwh.id
#   enabled_regions          = ["us-east-1"]
#   # Add provisioning role ARN
#   provisioning_role_arn = awscc_iam_role.example.arn
#   manage_access_role_arn = awscc_iam_role.example.arn
# }

resource "awscc_datazone_domain" "example" {
  name                  = local.dz_domain_name
  domain_execution_role = awscc_iam_role.example.arn
  description           = "Datazone domain example"
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

resource "awscc_iam_role" "example" {
  role_name = "dz_role_example"
  path      = "/service-role/"
  assume_role_policy_document = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "datazone.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : var.source_account_id
          },
          "ForAllValues:StringLike" : {
            "aws:TagKeys" : "datazone*"
          }
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonDataZoneDomainExecutionRolePolicy"]
}

# Create the secret
# to force deletion
# aws secretsmanager delete-secret --secret-id $ARN --force-delete-without-recovery
resource "aws_secretsmanager_secret" "example" {
  name                    = "AmazonDataZone-rs_prov"
  description             = "An example secret managed by Terraform used for DZ"
  recovery_window_in_days = 0 # forces automatic deletion
  tags = {
    Environment          = "Production"
    AmazonDataZoneDomain = awscc_datazone_domain.example.id
  }
  lifecycle {
    prevent_destroy = true
  }
}

# Set the value for the secret
resource "aws_secretsmanager_secret_version" "example" {
  secret_id = aws_secretsmanager_secret.example.id
  secret_string = jsonencode({
    username = "awsuser"
    password = var.redshift_password
  })
}

# only creator will be able to add env to DZ project
resource "aws_datazone_project" "example" {
  domain_identifier   = awscc_datazone_domain.example.id
  name                = "Admin"
  description         = "Admin project wey"
  skip_deletion_check = true
}

resource "aws_datazone_project" "sales" {
  domain_identifier = awscc_datazone_domain.example.id
  name              = "Sales"
  # description         = "Admin project wey"
  skip_deletion_check = true
}

resource "aws_datazone_project" "marketing" {
  domain_identifier = awscc_datazone_domain.example.id
  name              = "Marketing"
  # description         = "Admin project wey"
  skip_deletion_check = true
}

# resource "awscc_datazone_environment_profile" "example" {
#   name                             = "Sales"
#   description                      = "Example environment profile"
#   aws_account_id                   = data.aws_caller_identity.current.account_id
#   aws_account_region               = "us-east-1"
#   domain_identifier                = awscc_datazone_domain.example.domain_id
#   # environment_blueprint_identifier = awscc_datazone_environment_blueprint_configuration.example.environment_blueprint_id
# # resource "aws_datazone_environment_blueprint_configuration" "example" {
#   environment_blueprint_identifier = data.aws_datazone_environment_blueprint.default_dwh.id
#   # project_identifier               = awscc_datazone_project.example.project_id
#   project_identifier               = aws_datazone_project.example.id
# }

data "aws_caller_identity" "current" {}



