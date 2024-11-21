
locals {
  region = "us-east-1"
  dz_domain_name = "Marketing"
}

provider "aws" {
  region = local.region
}

terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
  }
}


# Configure the AWS CC Provider
provider "awscc" {
  region = local.region
}

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
  sensitive = true
}
