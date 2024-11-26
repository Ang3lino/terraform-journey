

# Create a Log Group
resource "awscc_logs_log_group" "example" {
  log_group_name = "example"
}

resource "awscc_datazone_domain" "example" {
  name                  = local.dz_domain_name
  domain_execution_role = awscc_iam_role.example.arn
  description           = "Datazone domain example"
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

resource "aws_datazone_environment_blueprint_configuration" "example" {
  domain_id                = awscc_datazone_domain.example.id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.default_dwh.id
  enabled_regions          = ["us-east-1"]
}

data "aws_datazone_environment_blueprint" "default_data_lake" {
  domain_id = awscc_datazone_domain.example.id
  name      = "DefaultDataLake"
  managed   = true
}

data "aws_datazone_environment_blueprint" "default_dwh" {
  domain_id = awscc_datazone_domain.example.id
  name      = "DefaultDataWarehouse"
  managed   = true
}

output "dz_default_data_lake" {
  value = data.aws_datazone_environment_blueprint.default_data_lake.id
}

output "dz_default_dwh" {
  value = data.aws_datazone_environment_blueprint.default_dwh.id
}

resource "awscc_iam_role" "example" {
  path = "/service-role/"
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


variable "source_account_id" {
  type        = string
  description = "Source AWS account id"
  sensitive   = true
}

# output "dz_domain_url" {
#   value = awscc_datazone_domain.example.url
# }

# Create the secret
resource "aws_secretsmanager_secret" "example" {
  name        = "AmazonDataZone-rs_prov"
  description = "An example secret managed by Terraform used for DZ"
  tags = {
    Environment          = "Production"
    AmazonDataZoneDomain = awscc_datazone_domain.example.id
  }
}

# only creator will be able to add env to DZ project
resource "aws_datazone_project" "example" {
  domain_identifier   = awscc_datazone_domain.example.id
  name                = "Admin"
  description         = "Admin project wey"
  skip_deletion_check = true
}

# Set the value for the secret
resource "aws_secretsmanager_secret_version" "example" {
  secret_id = aws_secretsmanager_secret.example.id
  secret_string = jsonencode({
    username = "awsuser"
    password = var.redshift_password
  })
}
